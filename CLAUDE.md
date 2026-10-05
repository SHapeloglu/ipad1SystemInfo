# CLAUDE.md — iPad1SystemInfo

Lightweight system information / monitoring app for **iPad 1 / iOS 5.1.1 / armv7 / jailbreak**. Two tabs: **Overview** (device & iOS info, CPU, RAM, storage, battery, Wi-Fi IP/MAC + RX/TX totals and live rate, Bluetooth power/connection state) refreshed every second, and **Processes** (name + PID) refreshed every three seconds. Objective-C, UIKit, **non-ARC**, Theos. Version `0.1-alpha1` (`control`).

- GitHub: https://github.com/SHapeloglu/ipad1SystemInfo
- Part of the iPad 1 app family (iPad1VNC, iPad1Files, iPad1FTPDownloader, iPad1Terminal, iPad1Player, iPad1PDFReader, ipad1MailBox, ipad1docx, iPad1WebBrowser). Family ownership rules: `INTEGRATION.md` in iPad1FTPDownloader / iPad1Files. **This app only observes the device; it does not own file management, transfers, terminal or process control.**
- Read first: `ARCHITECTURE.md` (components, data sources, constraints) → `TASK.md` → `SESSION.md`.

## Build & install

```bash
make clean && make package FINALPACKAGE=1        # ARCHS=armv7, TARGET=iphone:clang:6.1:5.1, -fno-objc-arc
# copy the .deb to the iPad with legacy ssh-rsa options (see iPad1VNC PROJECT_CONTEXT.md §10), then:
dpkg -i /var/mobile/com.shapeloglu.ipad1systeminfo_<VER>_iphoneos-arm.deb
```

`after-install` kills the running app (`killall -9 iPad1SystemInfo`).

## Rules

- iOS 5.1.1 APIs only; manual retain/release; no Swift/ARC/Auto Layout; no chart libraries.
- **All low-level metric collection lives in `SystemMetrics`** (`generalRows`, `cpuRows`, `memoryRows`, `storageRows`, `networkRows`, `bluetoothRows`, `batteryRows`, `processes`). View controllers must not call Mach/sysctl/getifaddrs directly.
- Bluetooth uses the private `BluetoothManager.framework` loaded dynamically — never hard-link it or add private headers; show `Unavailable` instead of crashing, and never fabricate Bluetooth RX/TX numbers.
- Any history/graph buffer must be bounded (≈60 samples). Timers must be invalidated when views disappear (1 s overview / 3 s process refresh cost CPU on an A4).
- Physical-device testing is authoritative; don't mark a feature done before it runs on the iPad.
- At session end, add an entry to `SESSION.md` and update `TASK.md`.
