# iPad1SystemInfo

Hafif sistem bilgi ve izleme uygulaması. Özellikle **iPad 1 / iOS 5.1.1 / armv7 / jailbreak / Theos / non-ARC** hedefi için tasarlanmıştır.

## v0.1-alpha1 hedefleri

- Cihaz ve iOS bilgileri
- CPU kullanımı
- RAM kullanımı
- Disk kullanımı
- Pil seviyesi ve şarj durumu
- Wi-Fi IP ve MAC adresi
- Wi-Fi toplam RX/TX ve anlık indirme/yükleme hızı
- Bluetooth açık/kapalı ve bağlantı durumu (eski iOS private framework üzerinden, erişilebildiğinde)
- Çalışan process adı ve PID listesi

## Derleme

```bash
make clean
make package FINALPACKAGE=1
```

Hedef cihaz: iPad 1, iOS 5.1.1, armv7.

> Not: Bluetooth bilgisi iOS 5.x private API davranışına bağlıdır. Uygulama private framework bulunamadığında çökmek yerine `Unavailable` gösterir.
