# Metal Slug 5 - native static recompilation

**Metal Slug 5 (SNK Playmore, 2003 / MAME set `mslug5`) running as a native PC
program: its 68000 program is translated ahead of time into C and executed
against a model of the MVS board by
[neogeorecomp](https://github.com/sp00nznet/neogeorecomp).**

Two deliverables are produced:

| Platform | Artifact |
|---|---|
| Windows x64 | `dist/windows/Metal Slug 5-Windows-x64/Metal Slug 5.exe` |
| Steam Deck / Linux x86_64 | `dist/steamdeck/Metal Slug 5-SteamDeck-x86_64.AppImage` |

The game's own code runs natively. The real MVS system ROM boots the board,
checks its checksum and RAM, shows the SNK eye-catcher, handles coins and
credits, and calls the cartridge exactly as on hardware. There is no BIOS HLE
and no emulator frontend. The Musashi interpreter remains as the correctness
oracle and as the fallback for code the flat dispatch cannot safely identify
(measured below).

> **No game data here.** You need your own legally obtained dumps of the MAME
> `mslug5` set and the `neogeo` system ROMs. The decrypted ROMs and the
> recompiled C are generated from your dump on your machine into `build-*/`;
> they are never committed or distributed.

## Status

**v0.1.0, alpha - boots, runs attract mode and plays Mission 1 on recompiled
code, with continuous native audio.**

| Area | State |
|---|---|
| Boot | Real MVS BIOS (`sp-s2.sp1`) -> eye-catcher -> intro -> title -> Mission 1 |
| Input / credits | Coin, Start, directions, A/B/C/D tested through the BIOS and gameplay |
| Gameplay | 1P game started from the title, movement, jumps, shooting, grenades and the knife over a scripted Mission 1 session |
| Graphics | Sprites, backgrounds, palettes, fix layer, raster effects; title and in-game frames captured |
| Audio | The real Z80 M1 driver and YM2610 run: music starts at the same point as MAME 0.242 (about 17 s) and is continuous through the captured session. Peak 30,104; not subjectively auditioned |
| Native coverage | **100.00%** on the 4,000-frame coin/start verify (76 interpreted instructions, 0 uncovered); **96.40%** over 12,000 coin/start frames; **93.24%** over 26,000 `play.txt` frames; 0 uncovered addresses after the 383-entry profile pass |
| `--verify` | 3,542,779 blocks over 4,000 coin/start frames, **0 register/flag/memory mismatches** (20,040 dynamic cycle-count differences; no state divergence) |
| Windows | Release exe built with MSVC x64 + SDL2; headless launch tested |
| Steam Deck | Native Linux x86_64 AppImage built and launched headless/fullscreen under WSL2; **not tested on physical Deck hardware** |
| License | PolyForm Noncommercial 1.0.0 (confirmed) |

### The supplied set is the original encrypted release

The `mslug5.zip` in `game/` is the MAME `mslug5` set (CRCs verified):

```
268-p1cr.p1 / 268-p2cr.p2   4 MB each  NEO-PVC encrypted program
268-c1c..c8c.c1..c8         8 MB each  NEO-CMC 7050 encrypted graphics
268-m1.m1                   512 KB     CMC50-encrypted Z80 program
268-v1c.v1 / 268-v2c.v2     8 MB each  NEO-PCM2-scrambled ADPCM samples
```

The encrypted board has **no S ROM**: the 128 KB fixed-layer data lives at the
end of the C ROMs and is extracted after CMC50 decryption.

`tools/decrypt.c` implements, at build time:

* MAME's `pvc_prot_device::mslug5_decrypt_68k()` for the 8 MB program.
* MAME's `cmc50_gfx_decrypt()` with `MSLUG5_GFX_KEY = 0x19`, then
  `sfix_decrypt()` to extract the 128 KB fixed layer.
* MAME's `cmc50_m1_decrypt()` for the 512 KB M1.
* MAME's `pcm2_prot_device::swap(..., 2)` for the two 8 MB V ROMs.
* Copy-through of the four BIOS files.

The prepared P ROM, M1 and 16 MB V region were compared byte-for-byte with the
regions MAME 0.242 builds (`cslot1:maincpu`, `cslot1:audiocpu`,
`cslot1:ymsnd:adpcma`) and match. The prepared files live only in the build
directory.

### Cart registers and layout

Metal Slug 5 uses the NEO-PVC protection chip, the same generic board model as
KOF 2003:

* 8 KB of cartridge RAM at `$2FE000-$2FFFFF`.
* The 68k writes a 24-bit byte address to `$2FFFF0/$2FFFF2`; the P-ROM window
  base is that address plus `$100000`.
* The colour pack/unpack registers at `$1FE0`/`$1FE8` are modelled.
* `NG_PROT_PVC` is a generic chip model; `src/game.c` only supplies the ROM
  layout.

### Cross-title audio repair

While bringing up this title the runtime's Z80 timer/latch handling was
re-audited. The substantive fix is generic and is now shared by Garou, KOF '96,
KOF '97, KOF 2000, Metal Slug 3, KOF 2003 and Metal Slug 5:

* **Do not reset the Z80 when the BIOS hands the sound ROM to the cartridge.**
  MAME's `set_use_cart_audio()` only switches the ROM bank. Resetting the CPU
  there discards the BIOS-to-cart handshake; Metal Slug 5's cart driver then
  initialises and never starts a song (silent audio). Switching the bank while
  keeping the Z80, its RAM and the NEO-ZMC latches live gives the same audio
  timeline as MAME.
* Take the **modular difference** of the Z80 cycle counter. `z80.cyc` is a
  `unsigned long`, which is 32-bit on MSVC and wraps after about 18 minutes at
  4 MHz; the old signed/size-based delta broke audio after that.
* Implement the **high YM2610 data port** (`$07`) so drivers that read ADPCM-B
  data do not see zero.

The previous M1 bank-mask and per-frame `audio_sync()` fixes remain in place.

## Building

> **Repository policy:** this public repository is source-only and omits
> CMake files. The buildable source archive, including the two
> `CMakeLists.txt` files, is attached to the `v0.1.0` release as
> `Metal-Slug-5-Source-v0.1.0.zip`. Extract that archive before using the
> commands below.

### Windows x64

```
cmake -S . -B build-windows -G "Visual Studio 18 2026" -A x64 ^
  -DMSLUG5_ROM_DIR=C:/path/to/unzipped/sets ^
  -DSDL2_DIR=C:/path/to/SDL2-2.32.10/cmake
cmake --build build-windows --config Release --parallel
```

Outputs `build-windows/Release/Metal Slug 5.exe`, `mslug5_decrypt.exe`, the
prepared `roms/`, and the generated C. Without `MSLUG5_ROM_DIR` the player
builds interpreter-only.

### Linux / Steam Deck

```
cmake -S . -B build-linux -DCMAKE_BUILD_TYPE=Release \
  -DMSLUG5_ROM_DIR=/path/to/unzipped/sets
cmake --build build-linux --parallel

./packaging/appimage/build-appimage.sh /path/to/unzipped/sets
```

The AppImage build stages `MetalSlug5`, `mslug5_decrypt`, SDL2, the desktop
file, icon, licences and docs, then runs `appimagetool`.

## Running

```
Metal\ Slug\ 5 --rom-path /path/to/prepared/roms
```

Keyboard: arrows, **Z X C V** = A B C D, **5** coin, **1/2** start,
**3** select, **9** service, **F2** test, **F11** fullscreen, **Esc** quit.
Gamepad: D-pad/left stick, **A B X Y** = Neo Geo A B C D, Start, Back = coin,
left shoulder = select.

A 1P game needs a coin before Start. The AppImage's AppRun adds `--fullscreen`
on Steam Deck and keeps the Neo Geo 4:3 picture pillarboxed on the 1280x800
16:10 panel.

## Tests

```
# interpreted boot and stills
"Metal Slug 5" --headless --interp --rom-path build-linux/roms \
  --frames 1500 --screenshot 600:bios.png --screenshot 1000:title.png

# coin/start and gameplay
"Metal Slug 5" --headless --rom-path build-linux/roms --frames 4000 \
  --input tests/coin_start.txt --screenshot 2200:game.png

# CPU verification and audio capture
"Metal Slug 5" --headless --rom-path build-linux/roms --frames 4000 \
  --input tests/coin_start.txt --verify --wav capture.wav
```

Measured results are in `docs/TESTING.md`; the hardware notes are in
`docs/COMPATIBILITY.md`; the ROM tables and hashes are in
`docs/ROM-VALIDATION.md`.

## Known limitations

* The full game (every mission, weapon, vehicle, boss, ending and route) has
  not been exhaustively tested. The verified session covers boot, coin/start,
  Mission 1 movement and combat, and a long attract/play soak.
* `--verify` reports cycle-count differences (for example `$00479E`, native
  3494 vs interpreter 3500) even with 0 register/flag/memory mismatches. These
  are dynamic-cycle accounting differences, not state divergence; audio
  continuity is checked separately.
* Subjective audio quality, physical Steam Deck hardware, Steam Input and
  physical controllers were not available in this environment.
* The 114/76 interpreted instructions reported by some runs are bank-window
  fallback instructions, not audio.

## Licensing

The original project code is licensed under **PolyForm Noncommercial 1.0.0**;
see `LICENSE` and `LICENSE-STATUS.md`.

`neogeorecomp/` is upstream MIT. Musashi and z80 are MIT; ymfm and the MAME
Neo Geo driver reference algorithms are BSD-3-Clause; SDL2 is zlib. Verbatim
texts are in `neogeorecomp/LICENSES/` and `packaging/windows/SDL2.txt`. SNK
Playmore game data and the Neo Geo BIOS are not licensed or distributed here.

