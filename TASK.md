# TASK.md — iPad1SystemInfo

## Sıradaki

- [ ] `0.1-alpha1`'i derle ve fiziksel iPad 1'de doğrula: Genel Bakış'taki her satır makul bir değer gösteriyor (CPU % yük altında değişiyor, RAM `hw.memsize` ile uyumlu, `/var/mobile` depolama, pil seviyesi/durumu, `en0` IP/MAC ve RX/TX farkları), Süreçler sekmesi PID'leri listeliyor
- [ ] Uygulamanın 1 sn / 3 sn yenilemedeki kendi CPU/RAM maliyetini ölç; gerekirse sıklığı düşür veya uygulama arka plana geçince zamanlayıcıları duraklat
- [ ] `BluetoothManager.framework` yüklenemediğinde Bluetooth satırının çökmeden `Unavailable`'a düştüğünü doğrula
- [ ] Sekme değişiminde / arka planda zamanlayıcıların iptal edildiğini doğrula (gizliyken iş yapılmıyor)

## Devam eden

_(yok)_

## Tamamlanan

- [x] 2026-10-05 — CLAUDE/TASK/BACKLOG/SESSION kaynak koddan yeniden yazıldı
- [x] 2026-09-17 — v0.1-alpha1 temel sürümü (Genel Bakış + Süreçler sekmeleri, `SystemMetrics`)
