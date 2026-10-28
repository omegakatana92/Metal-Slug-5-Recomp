# Cross-title sound repair - 2026-10-27 (second pass)

Games: **Garou: Mark of the Wolves**, **KOF '96**, **KOF '97**, **KOF 2000**,
**Metal Slug 3**, plus **KOF 2003** and the new **Metal Slug 5** port.

## Root cause

The runtime reset the Z80 whenever the system latch switched the sound ROM
between the BIOS SM1 and the cartridge M1:

```c
s_use_bios_rom = bios;
audio_reset();              /* wrong */
```

MAME's `neogeo_base_state::set_use_cart_audio()` only changes the ROM bank
(`m_bank_audio_main->set_entry()`); it does **not** reset the Z80, its RAM or
the NEO-ZMC bank latches. Metal Slug 5's cart driver depends on the
BIOS-to-cart handshake: with the reset it initialises the YM2610 and then never
loads a song, so only the BIOS music is heard. The same class of handshake
loss can affect late carts generally.

Two smaller generic defects were fixed at the same time:

* `z80.cyc` is `unsigned long`, which is 32-bit on MSVC. After about 18 minutes
  at 4 MHz it wraps; the old `s_z.cyc - before` delta then becomes huge. The
  runtime now takes the modular difference in `uint32_t`.
* The YM2610 high **data** port (`$07`, ADPCM-B data) returned 0. It now reads
  from ymfm like the high status port.

The earlier M1 bank-mask fix and the per-frame `audio_sync()` in
`audio_take_samples()` remain.

## Files changed

For each project's vendored `neogeorecomp/src/audio.c`:

* `audio_select_bios_rom()`: switch `s_use_bios_rom` only; no `audio_reset()`.
* `audio_sync()`: `uint32_t before` / modular delta.
* `ym_read()`: `case 3` returns `ym2610_read(3)`.

For each `neogeorecomp/src/window_sdl.c`: include `<stdlib.h>` (MSVC was
implicitly declaring `getenv`; C4013).

No game-specific addresses, ROM patches or title branches were added.

## Measured results (5,000-frame headless captures, native)

| Game | Capture | Peak | Silent runs after boot | Result |
|---|---|---:|---|---|
| Garou | `tests/play_long.txt` | 21,216 | 0-9 s boot only | continuous |
| KOF '96 | `tests/play.txt` | 14,026 | boot + short early attract gaps | continuous |
| KOF '97 | `tests/play_long.txt` | 12,473 | 60-77 s HOW-TO-PLAY, 79-82 s transition | continuous from 83 s |
| KOF 2000 | `tests/coin_start.txt` | 22,545 | 0-7 s boot only | continuous |
| Metal Slug 3 | `tests/play.txt` | 25,298 | 0-13 s boot, 22-29 s attract gap | continuous through Mission 1 |
| KOF 2003 | `tests/coin_start.txt` | 10,110 | 0-3 s boot only | continuous |
| Metal Slug 5 | `tests/coin_start.txt` | 30,104 | 0-16 s boot/title | continuous from ~17 s |

Metal Slug 5's music timeline now matches MAME 0.242: both start around 17 s
with the same coin/start input. Garou/KOF '96/KOF 2000/ Metal Slug 3 were
already continuous after the first-pass M1/output fixes; they were rebuilt from
the corrected handshake so the source and delivered binaries agree.

`--verify` on Metal Slug 5, 4,000 coin/start frames: **3,542,779 blocks, 0
register/flag/write mismatches**; 20,040 dynamic cycle-count differences (for
example native 3,494 vs interpreter 3,512 at `$00479E`), which do not change
state.

## Delivered artifacts

* Windows: rebuilt `Release` executables in each project's
  `build-windows/Release` (KOF 2000 uses `build/Release`), copied into
  `dist/windows/*-Windows-x64/`.
* Steam Deck: rebuilt native Linux binaries and AppImages in
  `dist/steamdeck/`; the previous files are kept as `*.pre-soundfix2`.
* Metal Slug 5: new Windows package and
  `Metal Slug 5-SteamDeck-x86_64.AppImage`.

## Not tested

* Subjective listening, physical Steam Deck/SteamOS audio, physical gamepads.
* Two-player, service menus, every music track in every game.
* The KOF '97 5,000-frame window still contains the game's own HOW-TO-PLAY
  tutorial silence at 60-77 s; the 12,000/19,000-frame project checks cover
  the post-83 s match.


