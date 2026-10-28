# Changelog

## 0.1.0 - 2026-10-27

- New Metal Slug 5 project (MAME `mslug5`, NGM-2680): NEO-PVC program, NEO-CMC
  7050 graphics, CMC50 M1, NEO-PCM2 V ROMs, 128 KB embedded S ROM.
- Build-time `mslug5_decrypt` tool; prepared P/M1/V regions match MAME 0.242.
- NEO-PVC banking and cart RAM through the generic `NG_PROT_PVC` runtime.
- Interpreted and recompiled boot, coin/start, Mission 1 gameplay and
  screenshots.
- Profile pass for runtime-only entry points.
- Generic audio fix shared with Garou, KOF '96, KOF '97, KOF 2000, Metal Slug 3
  and KOF 2003: do not reset the Z80 on the SM1 -> cart M1 handshake; use a
  modular 32-bit Z80 cycle delta; read the high YM2610 data port.
- Windows x64 Release build, Linux x86_64 build and Steam Deck AppImage
  packaging.
