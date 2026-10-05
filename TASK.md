# TASK.md — iPad1SystemInfo

## Next

- [ ] Build `0.1-alpha1` and validate on the physical iPad 1: every Overview row shows a sane value (CPU % changes under load, RAM matches `hw.memsize`, `/var/mobile` storage, battery level/state, `en0` IP/MAC and RX/TX deltas), Processes tab lists PIDs
- [ ] Measure the app's own CPU/RAM cost at 1 s / 3 s refresh; lower the rate or pause timers when the app is backgrounded if needed
- [ ] Confirm Bluetooth row degrades to `Unavailable` without crashing when `BluetoothManager.framework` cannot be loaded
- [ ] Verify timers are invalidated on tab switch / background (no work while hidden)

## In progress

_(none)_

## Done

- [x] 2026-10-05 — CLAUDE/TASK/BACKLOG/SESSION rewritten from the source
- [x] 2026-09-17 — v0.1-alpha1 baseline (Overview + Processes tabs, `SystemMetrics`)
