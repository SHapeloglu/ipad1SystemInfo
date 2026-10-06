# CLAUDE.md — iPad1SystemInfo

**iPad 1 / iOS 5.1.1 / armv7 / jailbreak** için hafif sistem bilgisi / izleme uygulaması. İki sekme: saniyede bir yenilenen **Genel Bakış** (cihaz ve iOS bilgisi, CPU, RAM, depolama, pil, Wi-Fi IP/MAC + RX/TX toplamları ve anlık hız, Bluetooth güç/bağlantı durumu) ve üç saniyede bir yenilenen **Süreçler** (ad + PID). Objective-C, UIKit, **non-ARC**, Theos. Sürüm `0.1-alpha1` (`control`).

- GitHub: https://github.com/SHapeloglu/ipad1SystemInfo
- iPad 1 uygulama ailesinin parçası (iPad1VNC, iPad1Files, iPad1FTPDownloader, iPad1Terminal, iPad1Player, iPad1PDFReader, ipad1MailBox, ipad1docx, iPad1WebBrowser). Aile sahiplik kuralları: iPad1FTPDownloader / iPad1Files içindeki `INTEGRATION.md`. **Bu uygulama yalnızca cihazı gözlemler; dosya yönetimi, transfer, terminal veya süreç kontrolü sahiplenmez.**
- Önce oku: `ARCHITECTURE.md` (bileşenler, veri kaynakları, kısıtlar) → `TASK.md` → `SESSION.md`.

## Derleme ve kurulum

```bash
make clean && make package FINALPACKAGE=1        # ARCHS=armv7, TARGET=iphone:clang:6.1:5.1, -fno-objc-arc
# .deb'i eski ssh-rsa seçenekleriyle iPad'e kopyala (bkz. iPad1VNC PROJECT_CONTEXT.md §10), ardından:
dpkg -i /var/mobile/com.shapeloglu.ipad1systeminfo_<VER>_iphoneos-arm.deb
```

`after-install` çalışan uygulamayı kapatır (`killall -9 iPad1SystemInfo`).

## Kurallar

- Yalnızca iOS 5.1.1 API'leri; manuel retain/release; Swift/ARC/Auto Layout yok; grafik kütüphanesi yok.
- **Tüm düşük seviyeli ölçüm toplama `SystemMetrics` içindedir** (`generalRows`, `cpuRows`, `memoryRows`, `storageRows`, `networkRows`, `bluetoothRows`, `batteryRows`, `processes`). View controller'lar Mach/sysctl/getifaddrs'i doğrudan çağırmamalı.
- Bluetooth özel `BluetoothManager.framework`'ü dinamik olarak yükler — asla sabit bağlama veya özel başlık ekleme; çökmek yerine `Unavailable` göster ve Bluetooth RX/TX sayılarını asla uydurma.
- Her geçmiş/grafik tamponu sınırlı olmalı (≈60 örnek). Görünümler kaybolunca zamanlayıcılar iptal edilmeli (1 sn genel bakış / 3 sn süreç yenilemesi A4'te CPU harcar).
- Belirleyici olan fiziksel cihaz testidir; iPad'de çalışmadan bir özelliği bitti diye işaretleme.
- Oturum sonunda `SESSION.md`'ye kayıt ekle ve `TASK.md`'yi güncelle. Tüm `.md` dokümanları Türkçe yazılır.
