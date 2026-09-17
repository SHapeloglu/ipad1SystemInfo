#import <Foundation/Foundation.h>
#import <stdint.h>

@interface SystemMetrics : NSObject {
    uint64_t _prevCPUUser;
    uint64_t _prevCPUSystem;
    uint64_t _prevCPUNice;
    uint64_t _prevCPUIdle;
    BOOL _cpuInitialized;

    uint64_t _prevNetworkRX;
    uint64_t _prevNetworkTX;
    NSTimeInterval _prevNetworkTime;
    BOOL _networkInitialized;

    void *_bluetoothHandle;
    id _bluetoothManager;
}

- (NSArray *)generalRows;
- (NSArray *)cpuRows;
- (NSArray *)memoryRows;
- (NSArray *)storageRows;
- (NSArray *)networkRows;
- (NSArray *)bluetoothRows;
- (NSArray *)batteryRows;
- (NSArray *)processes;

@end
