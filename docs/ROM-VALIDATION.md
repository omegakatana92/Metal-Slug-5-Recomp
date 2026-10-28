# ROM validation - Metal Slug 5

Input set: MAME `mslug5` (MVS, encrypted) plus `neogeo` BIOS.
Toolkit: neogeorecomp v0.2.0 (`af96b2b`).
Reference: MAME 0.242 on Ubuntu 22.04.

## Input files

| File | Size | CRC-32 | Role |
|---|---:|---|---|
| `268-p1cr.p1` | 4,194,304 | `d0466792` | NEO-PVC encrypted P ROM, low 32-bit words |
| `268-p2cr.p2` | 4,194,304 | `fbf6b61e` | NEO-PVC encrypted P ROM, high 32-bit words |
| `268-c1c.c1` | 8,388,608 | `ab7c389a` | CMC50 encrypted sprites, plane 0/1 |
| `268-c2c.c2` | 8,388,608 | `3560881b` | CMC50 encrypted sprites, plane 2/3 |
| `268-c3c.c3` | 8,388,608 | `3af955ea` | CMC50 encrypted sprites |
| `268-c4c.c4` | 8,388,608 | `c329c373` | CMC50 encrypted sprites |
| `268-c5c.c5` | 8,388,608 | `959c8177` | CMC50 encrypted sprites |
| `268-c6c.c6` | 8,388,608 | `010a831b` | CMC50 encrypted sprites |
| `268-c7c.c7` | 8,388,608 | `6d72a969` | CMC50 encrypted sprites |
| `268-c8c.c8` | 8,388,608 | `551d720e` | CMC50 encrypted sprites |
| `268-m1.m1` | 524,288 | `4a5a6e0e` | CMC50 encrypted Z80 program |
| `268-v1c.v1` | 8,388,608 | `ae31d60c` | NEO-PCM2 scrambled ADPCM |
| `268-v2c.v2` | 8,388,608 | `c40613ed` | NEO-PCM2 scrambled ADPCM |

BIOS files used: `sp-s2.sp1` (`9036d879`), `sfix.sfix` (`c2ea0cfd`),
`sm1.sm1` (`94416d67`), `000-lo.lo` (`5a86cff2`).

## Prepared output

| File | Size | CRC-32 | Notes |
|---|---:|---|---|
| `268-pd.bin` | 8,388,608 | `f403831e` | PVC-decrypted, 68k byte order |
| `268-s1.s1` | 131,072 | `64952683` | extracted fixed layer |
| `268-m1c.m1` | 524,288 | `39f3cbba` | CMC50-decrypted Z80 |
| `268-v1c.v1` | 8,388,608 | (region) | PCM2 swap 2 |
| `268-v2c.v2` | 8,388,608 | (region) | PCM2 swap 2 |

The prepared P ROM, M1 and the concatenated 16 MB V region were compared
byte-for-byte with MAME's `cslot1:maincpu`, `cslot1:audiocpu` (offset
`$10000`) and `cslot1:ymsnd:adpcma` regions and matched.

## Encryption / protection

* **Program:** NEO-PVC, `mslug5_decrypt_68k()` (30-byte XOR streams, 16-bit
  bit permutation, 64 KB block permutation), then a 16-bit byte swap into 68k
  order.
* **Graphics:** NEO-CMC 7050, `MSLUG5_GFX_KEY = 0x19`, then `sfix_decrypt()`
  for the 128 KB fixed layer stored at the end of the 64 MB C data.
* **Sound CPU:** CMC50 M1 decryption; the key is the 16-bit sum of the first
  64 KB, as on hardware.
* **Samples:** NEO-PCM2 `swap(..., 2)` (`addrs[2] = $FE2CF6/$4E001`,
  `xordata[2] = C3 FD 81 AC 6D E7 BF 9E`).
* **Banking:** NEO-PVC 8 KB RAM at `$2FE000-$2FFFFF`; writes at
  `$2FFFF0/$2FFFF2` form the 24-bit byte address and the 1 MB window base is
  address + `$100000`. There is no `ng_bank_map`.

The original archive is never modified. Prepared files are written only into
`build-*/roms` and are not packaged.
