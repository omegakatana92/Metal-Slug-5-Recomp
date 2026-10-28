# Testing report - Metal Slug 5

Environment: Windows 11 x64, MSVC 19.51 (Visual Studio 18 2026), CMake 4.3;
Ubuntu 22.04 under WSL2, GCC 11.4, SDL2 2.0.20. MAME 0.242 was used as the
ROM/audio oracle. No physical Steam Deck or gamepad was available.

## 1. ROM validation

Input CRCs match MAME's `mslug5` set. The prepared P ROM, M1 and 16 MB V
region match MAME's decrypted regions byte-for-byte. See
`ROM-VALIDATION.md`.

## 2. Interpreted boot

```
./"Metal Slug 5" --headless --interp --rom-path build-linux/roms \
  --frames 1500 --screenshot 600:shots/bios.png \
  --screenshot 1000:shots/title.png --screenshot 1499:shots/late.png
```

Observed: BIOS "INSERT COIN" eye-catcher at frame 600; the Metal Slug 5 title
at frame 1000. This tests the board model without recompiled code.

## 3. Coin/start and gameplay

```
./"Metal Slug 5" --headless --interp --rom-path build-linux/roms \
  --frames 4000 --input tests/coin_start.txt \
  --screenshot 2200:shots/after_start.png --screenshot 3000:shots/game.png
```

Observed: coin and Start enter the game; the boat/jungle opening renders;
movement, jumping, shooting and grenades run. The script is a coverage aid,
not a full-game claim.

## 4. Native build and verification

```
./"Metal Slug 5" --headless --rom-path build-linux/roms --frames 4000 \
  --input tests/coin_start.txt --verify --wav capture.wav
```

Result:

```
[neogeorecomp] mslug5: 36096 recompiled entry points
[verify] 3542779 blocks checked, 0 mismatches, 20040 cycle-count differences
[exec] native blocks 3542779, native instructions 78608090,
       interpreted instructions 76 (100.00% native), 0 uncovered entry points
```

`0 mismatches` means registers, flags and the complete write sequence match
Musashi. The cycle-count differences (for example `$00479E`, native 3494 vs
interpreter 3512) are dynamic-cycle accounting differences; they do not change
state.

## 5. Profile pass and final coverage

The `profile` target runs 6,000 attract frames, 12,000 coin/start frames and
26,000 frames of `tests/play.txt`, writing `--dump-misses` back into
`build-linux/entries.txt`. It found 225, 344 and 371 runtime-only entry points;
the final list has 383 entries and the generated C was regenerated from it.

Final native runs:

| Session | Frames | Native instructions | Interpreted | Native | Uncovered |
|---|---:|---:|---:|---:|---:|
| coin/start verify | 4,000 | 78,608,090 | 76 | **100.00%** | 0 |
| coin/start | 12,000 | 222,538,444 | 8,320,558 | **96.40%** | 0 |
| `play.txt` | 26,000 | 459,139,546 | 33,281,968 | **93.24%** | 0 |

The 12,000/26,000-frame interpretation is bank-window fallback code, not
uncovered entry points; all reached addresses have a dispatch entry.

## 6. Audio

```
./"Metal Slug 5" --headless --rom-path build-linux/roms --frames 4000 \
  --input tests/coin_start.txt --wav native.wav
```

Native capture: 67.6 s, 55,555 Hz stereo, peak 30,104, continuous music from
about 17 s through the capture. The MAME 0.242 reference with the same
coin/start input has music from about 17 s and the same later continuity.
The pre-fix runtime was silent after the BIOS music; the fix is the Z80
ROM-select handshake (see README).

## 7. Windows

Release `Metal Slug 5.exe` built with MSVC x64. Headless coin/start run
completed with `0 uncovered entry points`, and the WAV capture was non-silent.
A windowed `--scale 1 --frames 300` launch of the packaged exe also completed.

## 8. Not tested

- Physical Steam Deck, Gaming Mode, Steam Input hardware.
- Physical gamepads.
- Subjective audio quality / volume balance.
- Every mission, weapon, vehicle, boss and ending.

