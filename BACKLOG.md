# BACKLOG.md — iPad1SystemInfo

Ideas, not yet scheduled. Respect the family ownership rules: observe only.

- Small rolling charts (≤60 samples) for CPU, RAM and Wi-Fi rate, drawn with Core Graphics.
- Per-process CPU/RAM (if `proc_pidinfo`-style data is reachable on iOS 5 without heavy cost).
- Thermal / uptime / boot time rows.
- Copy-to-clipboard or export of a diagnostics snapshot (text) for sibling apps' bug reports.
- Low-memory warning counter (how often iOS sent memory warnings) — useful for tuning sibling apps on 256 MB.
- Process kill is **out of scope** unless the family decides otherwise (would belong closer to iPad1Terminal).
