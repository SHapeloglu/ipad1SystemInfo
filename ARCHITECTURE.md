# Mimari

## Hedef

- iPad 1
- iOS 5.1.1
- armv7
- `/Applications` altına jailbreak kurulumu
- Theos + iPhoneOS 6.1 SDK
- Objective-C, manuel referans sayımı (non-ARC)

## Bileşenler

- `AppDelegate`: sekme tabanlı uygulama iskeletini oluşturur.
- `OverviewViewController`: cihaz ölçümlerini saniyede bir hafifçe yeniler.
- `ProcessesViewController`: üç saniyede bir yenilenen süreç/PID listesi.
- `SystemMetrics`: tüm düşük seviyeli ölçüm toplama. Arayüz kodu sistem API'lerini doğrudan okumaz.

## Veri kaynakları

- CPU: Mach `HOST_CPU_LOAD_INFO` fark sayaçları.
- RAM: Mach VM istatistikleri artı `hw.memsize`.
- Depolama: `/var/mobile` için Foundation dosya sistemi öznitelikleri.
- Ağ: `en0` üzerinde `getifaddrs()` / `AF_LINK` sayaçları.
- Bluetooth: dinamik olarak yüklenen eski `BluetoothManager.framework`; özel başlık dosyası veya sabit framework bağlantısı yok.
- Süreçler: `sysctl(CTL_KERN, KERN_PROC, KERN_PROC_ALL)`.
- Pil: `UIDevice` pil izleme.

## iPad 1 kısıtları

Uygulama bilinçli olarak Swift, ARC, güncel API'ler, ağır grafik kütüphaneleri ve sınırsız geçmiş tamponlarından kaçınır. Gelecekteki grafikler en fazla küçük bir döner pencere (örneğin 60 örnek) tutmalıdır.

## Bluetooth trafiği

iOS 5, Wi-Fi için kullanılan normal ağ arayüzü istatistikleri üzerinden güvenilir Bluetooth bayt sayaçları sunmaz. v0.1-alpha1, özel framework mevcut olduğunda Bluetooth güç/bağlantı durumunu bildirir, ancak RX/TX değerleri uydurmaz.
