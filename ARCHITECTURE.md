# Architecture

## Target

- iPad 1
- iOS 5.1.1
- armv7
- Jailbreak installation under `/Applications`
- Theos + iPhoneOS 6.1 SDK
- Objective-C, manual reference counting (non-ARC)

## Components

- `AppDelegate`: creates the tab-based application shell.
- `OverviewViewController`: lightweight one-second refresh of device metrics.
- `ProcessesViewController`: process/PID list refreshed every three seconds.
- `SystemMetrics`: all low-level metric collection. UI code does not read system APIs directly.

## Data sources

- CPU: Mach `HOST_CPU_LOAD_INFO` delta counters.
- RAM: Mach VM statistics plus `hw.memsize`.
- Storage: Foundation filesystem attributes for `/var/mobile`.
- Network: `getifaddrs()` / `AF_LINK` counters on `en0`.
- Bluetooth: dynamically loaded legacy `BluetoothManager.framework`; no private headers or hard framework link.
- Processes: `sysctl(CTL_KERN, KERN_PROC, KERN_PROC_ALL)`.
- Battery: `UIDevice` battery monitoring.

## iPad 1 constraints

The app intentionally avoids Swift, ARC, modern APIs, heavy chart libraries and unbounded history buffers. Future charts should retain at most a small rolling window (for example 60 samples).

## Bluetooth traffic

iOS 5 does not expose reliable Bluetooth byte counters through the normal network interface statistics used for Wi-Fi. v0.1-alpha1 reports Bluetooth power/connection state where the private framework is available, but does not fabricate RX/TX values.
