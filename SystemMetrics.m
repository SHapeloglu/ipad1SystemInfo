#import "SystemMetrics.h"

#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <sys/sysctl.h>
#import <sys/types.h>
#import <sys/utsname.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <dlfcn.h>
#import <objc/message.h>

static NSDictionary *MetricRow(NSString *title, NSString *value) {
    if (value == nil) value = @"—";
    return [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", value, @"value", nil];
}

static NSString *FormatBytes(uint64_t bytes) {
    double value = (double)bytes;
    NSString *unit = @"B";
    if (value >= 1024.0) { value /= 1024.0; unit = @"KB"; }
    if (value >= 1024.0) { value /= 1024.0; unit = @"MB"; }
    if (value >= 1024.0) { value /= 1024.0; unit = @"GB"; }
    if ([unit isEqualToString:@"B"]) return [NSString stringWithFormat:@"%llu B", bytes];
    return [NSString stringWithFormat:@"%.2f %@", value, unit];
}

static NSDictionary *InterfaceInfo(const char *targetName) {
    struct ifaddrs *interfaces = NULL;
    NSString *ip = nil;
    NSString *mac = nil;
    uint64_t rx = 0;
    uint64_t tx = 0;

    if (getifaddrs(&interfaces) == 0) {
        struct ifaddrs *cursor = interfaces;
        while (cursor != NULL) {
            if (cursor->ifa_name != NULL && strcmp(cursor->ifa_name, targetName) == 0 && cursor->ifa_addr != NULL) {
                int family = cursor->ifa_addr->sa_family;
                if (family == AF_INET) {
                    char buffer[INET_ADDRSTRLEN];
                    struct sockaddr_in *address = (struct sockaddr_in *)cursor->ifa_addr;
                    if (inet_ntop(AF_INET, &address->sin_addr, buffer, sizeof(buffer)) != NULL) {
                        ip = [NSString stringWithUTF8String:buffer];
                    }
                } else if (family == AF_LINK) {
                    struct sockaddr_dl *sdl = (struct sockaddr_dl *)cursor->ifa_addr;
                    if (sdl->sdl_alen >= 6) {
                        unsigned char *addr = (unsigned char *)LLADDR(sdl);
                        mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                               addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]];
                    }
                    if (cursor->ifa_data != NULL) {
                        struct if_data *data = (struct if_data *)cursor->ifa_data;
                        rx = (uint64_t)data->ifi_ibytes;
                        tx = (uint64_t)data->ifi_obytes;
                    }
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(interfaces);
    }

    return [NSDictionary dictionaryWithObjectsAndKeys:
            (ip != nil ? ip : @"—"), @"ip",
            (mac != nil ? mac : @"—"), @"mac",
            [NSNumber numberWithUnsignedLongLong:rx], @"rx",
            [NSNumber numberWithUnsignedLongLong:tx], @"tx",
            nil];
}

static NSInteger CompareProcessPID(id left, id right, void *context) {
    NSInteger a = [[left objectForKey:@"pid"] integerValue];
    NSInteger b = [[right objectForKey:@"pid"] integerValue];
    if (a > b) return NSOrderedAscending;
    if (a < b) return NSOrderedDescending;
    return NSOrderedSame;
}

@implementation SystemMetrics

- (id)init {
    self = [super init];
    if (self) {
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];

        _bluetoothHandle = dlopen("/System/Library/PrivateFrameworks/BluetoothManager.framework/BluetoothManager", RTLD_LAZY);
        if (_bluetoothHandle != NULL) {
            Class bluetoothClass = NSClassFromString(@"BluetoothManager");
            SEL sharedSelector = NSSelectorFromString(@"sharedInstance");
            if (bluetoothClass != Nil && [bluetoothClass respondsToSelector:sharedSelector]) {
                id (*sendId)(id, SEL) = (id (*)(id, SEL))objc_msgSend;
                _bluetoothManager = [sendId((id)bluetoothClass, sharedSelector) retain];
            }
        }
    }
    return self;
}

- (NSArray *)generalRows {
    UIDevice *device = [UIDevice currentDevice];
    struct utsname systemInfo;
    uname(&systemInfo);

    NSString *machine = [NSString stringWithUTF8String:systemInfo.machine];
    NSTimeInterval uptime = [[NSProcessInfo processInfo] systemUptime];
    NSUInteger days = (NSUInteger)(uptime / 86400.0);
    NSUInteger hours = (NSUInteger)((uptime - (days * 86400.0)) / 3600.0);
    NSUInteger minutes = (NSUInteger)((uptime - (days * 86400.0) - (hours * 3600.0)) / 60.0);

    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    return [NSArray arrayWithObjects:
            MetricRow(@"Date", [formatter stringFromDate:[NSDate date]]),
            MetricRow(@"Name", [device name]),
            MetricRow(@"Model", machine),
            MetricRow(@"Device", [device model]),
            MetricRow(@"iOS", [device systemVersion]),
            MetricRow(@"Uptime", [NSString stringWithFormat:@"%lu d %02lu:%02lu", (unsigned long)days, (unsigned long)hours, (unsigned long)minutes]),
            nil];
}

- (NSArray *)cpuRows {
    host_cpu_load_info_data_t cpuInfo;
    mach_msg_type_number_t count = HOST_CPU_LOAD_INFO_COUNT;
    kern_return_t result = host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, (host_info_t)&cpuInfo, &count);
    if (result != KERN_SUCCESS) {
        return [NSArray arrayWithObject:MetricRow(@"CPU", @"Unavailable")];
    }

    uint64_t user = cpuInfo.cpu_ticks[CPU_STATE_USER];
    uint64_t system = cpuInfo.cpu_ticks[CPU_STATE_SYSTEM];
    uint64_t nice = cpuInfo.cpu_ticks[CPU_STATE_NICE];
    uint64_t idle = cpuInfo.cpu_ticks[CPU_STATE_IDLE];

    uint64_t dUser = user;
    uint64_t dSystem = system;
    uint64_t dNice = nice;
    uint64_t dIdle = idle;

    if (_cpuInitialized) {
        dUser = user - _prevCPUUser;
        dSystem = system - _prevCPUSystem;
        dNice = nice - _prevCPUNice;
        dIdle = idle - _prevCPUIdle;
    }

    _prevCPUUser = user;
    _prevCPUSystem = system;
    _prevCPUNice = nice;
    _prevCPUIdle = idle;
    _cpuInitialized = YES;

    uint64_t total = dUser + dSystem + dNice + dIdle;
    double userPercent = 0.0;
    double systemPercent = 0.0;
    double idlePercent = 0.0;
    if (total > 0) {
        userPercent = ((double)(dUser + dNice) * 100.0) / (double)total;
        systemPercent = ((double)dSystem * 100.0) / (double)total;
        idlePercent = ((double)dIdle * 100.0) / (double)total;
    }

    return [NSArray arrayWithObjects:
            MetricRow(@"User", [NSString stringWithFormat:@"%.1f%%", userPercent]),
            MetricRow(@"System", [NSString stringWithFormat:@"%.1f%%", systemPercent]),
            MetricRow(@"Idle", [NSString stringWithFormat:@"%.1f%%", idlePercent]),
            nil];
}

- (NSArray *)memoryRows {
    mach_port_t host = mach_host_self();
    vm_size_t pageSize = 0;
    host_page_size(host, &pageSize);

    vm_statistics_data_t vmStats;
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    kern_return_t result = host_statistics(host, HOST_VM_INFO, (host_info_t)&vmStats, &count);
    if (result != KERN_SUCCESS) {
        return [NSArray arrayWithObject:MetricRow(@"Memory", @"Unavailable")];
    }

    uint64_t totalMemory = 0;
    size_t size = sizeof(totalMemory);
    if (sysctlbyname("hw.memsize", &totalMemory, &size, NULL, 0) != 0 || totalMemory == 0) {
        totalMemory = ((uint64_t)vmStats.free_count + vmStats.active_count + vmStats.inactive_count + vmStats.wire_count) * (uint64_t)pageSize;
    }

    uint64_t freeMemory = (uint64_t)vmStats.free_count * (uint64_t)pageSize;
    uint64_t activeMemory = (uint64_t)vmStats.active_count * (uint64_t)pageSize;
    uint64_t inactiveMemory = (uint64_t)vmStats.inactive_count * (uint64_t)pageSize;
    uint64_t wiredMemory = (uint64_t)vmStats.wire_count * (uint64_t)pageSize;
    uint64_t usedMemory = activeMemory + inactiveMemory + wiredMemory;
    double percent = (totalMemory > 0) ? ((double)usedMemory * 100.0 / (double)totalMemory) : 0.0;

    return [NSArray arrayWithObjects:
            MetricRow(@"Total", FormatBytes(totalMemory)),
            MetricRow(@"Used", FormatBytes(usedMemory)),
            MetricRow(@"Free", FormatBytes(freeMemory)),
            MetricRow(@"Active", FormatBytes(activeMemory)),
            MetricRow(@"Inactive", FormatBytes(inactiveMemory)),
            MetricRow(@"Wired", FormatBytes(wiredMemory)),
            MetricRow(@"Usage", [NSString stringWithFormat:@"%.1f%%", percent]),
            nil];
}

- (NSArray *)storageRows {
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/var/mobile" error:&error];
    if (attributes == nil) {
        attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/" error:&error];
    }
    if (attributes == nil) {
        return [NSArray arrayWithObject:MetricRow(@"Storage", @"Unavailable")];
    }

    uint64_t total = [[attributes objectForKey:NSFileSystemSize] unsignedLongLongValue];
    uint64_t free = [[attributes objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
    uint64_t used = (total >= free) ? (total - free) : 0;
    double percent = (total > 0) ? ((double)used * 100.0 / (double)total) : 0.0;

    return [NSArray arrayWithObjects:
            MetricRow(@"Total", FormatBytes(total)),
            MetricRow(@"Used", FormatBytes(used)),
            MetricRow(@"Free", FormatBytes(free)),
            MetricRow(@"Usage", [NSString stringWithFormat:@"%.1f%%", percent]),
            nil];
}

- (NSArray *)networkRows {
    NSDictionary *info = InterfaceInfo("en0");
    NSString *ip = [info objectForKey:@"ip"];
    NSString *mac = [info objectForKey:@"mac"];
    uint64_t rx = [[info objectForKey:@"rx"] unsignedLongLongValue];
    uint64_t tx = [[info objectForKey:@"tx"] unsignedLongLongValue];

    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    double downRate = 0.0;
    double upRate = 0.0;
    if (_networkInitialized) {
        NSTimeInterval elapsed = now - _prevNetworkTime;
        if (elapsed > 0.0) {
            uint64_t deltaRX = (rx >= _prevNetworkRX) ? (rx - _prevNetworkRX) : 0;
            uint64_t deltaTX = (tx >= _prevNetworkTX) ? (tx - _prevNetworkTX) : 0;
            downRate = (double)deltaRX / elapsed;
            upRate = (double)deltaTX / elapsed;
        }
    }

    _prevNetworkRX = rx;
    _prevNetworkTX = tx;
    _prevNetworkTime = now;
    _networkInitialized = YES;

    BOOL active = ![ip isEqualToString:@"—"];
    return [NSArray arrayWithObjects:
            MetricRow(@"Wi-Fi", active ? @"ON" : @"OFF"),
            MetricRow(@"IP Address", ip),
            MetricRow(@"MAC Address", mac),
            MetricRow(@"Download", [NSString stringWithFormat:@"%@/s", FormatBytes((uint64_t)downRate)]),
            MetricRow(@"Upload", [NSString stringWithFormat:@"%@/s", FormatBytes((uint64_t)upRate)]),
            MetricRow(@"RX Total", FormatBytes(rx)),
            MetricRow(@"TX Total", FormatBytes(tx)),
            nil];
}

- (NSArray *)bluetoothRows {
    if (_bluetoothManager == nil) {
        return [NSArray arrayWithObjects:
                MetricRow(@"Bluetooth", @"Unavailable"),
                MetricRow(@"Traffic", @"Not exposed by iOS 5"),
                nil];
    }

    NSString *enabledText = @"Unknown";
    NSString *connectedText = @"Unknown";
    BOOL (*sendBool)(id, SEL) = (BOOL (*)(id, SEL))objc_msgSend;

    SEL enabledSelector = NSSelectorFromString(@"enabled");
    if ([_bluetoothManager respondsToSelector:enabledSelector]) {
        enabledText = sendBool(_bluetoothManager, enabledSelector) ? @"ON" : @"OFF";
    }

    SEL connectedSelector = NSSelectorFromString(@"connected");
    if ([_bluetoothManager respondsToSelector:connectedSelector]) {
        connectedText = sendBool(_bluetoothManager, connectedSelector) ? @"YES" : @"NO";
    }

    return [NSArray arrayWithObjects:
            MetricRow(@"Bluetooth", enabledText),
            MetricRow(@"Connected", connectedText),
            MetricRow(@"Traffic", @"Not exposed by iOS 5"),
            nil];
}

- (NSArray *)batteryRows {
    UIDevice *device = [UIDevice currentDevice];
    float level = [device batteryLevel];
    NSString *levelText = (level < 0.0f) ? @"Unknown" : [NSString stringWithFormat:@"%.0f%%", level * 100.0f];

    NSString *stateText = @"Unknown";
    switch ([device batteryState]) {
        case UIDeviceBatteryStateUnplugged: stateText = @"On Battery"; break;
        case UIDeviceBatteryStateCharging: stateText = @"Charging"; break;
        case UIDeviceBatteryStateFull: stateText = @"Full"; break;
        default: break;
    }

    return [NSArray arrayWithObjects:
            MetricRow(@"Level", levelText),
            MetricRow(@"State", stateText),
            nil];
}

- (NSArray *)processes {
    int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
    size_t length = 0;
    if (sysctl(mib, 4, NULL, &length, NULL, 0) != 0 || length == 0) {
        return [NSArray array];
    }

    struct kinfo_proc *processList = (struct kinfo_proc *)malloc(length);
    if (processList == NULL) {
        return [NSArray array];
    }

    if (sysctl(mib, 4, processList, &length, NULL, 0) != 0) {
        free(processList);
        return [NSArray array];
    }

    size_t count = length / sizeof(struct kinfo_proc);
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    size_t index;
    for (index = 0; index < count; index++) {
        pid_t pid = processList[index].kp_proc.p_pid;
        if (pid <= 0) continue;

        NSString *name = [NSString stringWithCString:processList[index].kp_proc.p_comm encoding:NSUTF8StringEncoding];
        if (name == nil || [name length] == 0) name = @"(unknown)";

        [result addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           name, @"name",
                           [NSNumber numberWithInt:pid], @"pid",
                           nil]];
    }

    free(processList);
    [result sortUsingFunction:CompareProcessPID context:NULL];
    return result;
}

- (void)dealloc {
    [_bluetoothManager release];
    if (_bluetoothHandle != NULL) dlclose(_bluetoothHandle);
    [super dealloc];
}

@end
