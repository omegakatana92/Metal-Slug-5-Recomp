# Hardware compatibility - Metal Slug 5

Metal Slug 5 (NGM-2680) is a late Neo Geo cartridge. MAME's `mslug5` set
describes the board as:

- **NEO-MVS PROGBK3S (2003.10.1)** with **NEO-PCM2** and **NEO-PVC**
- **NEO-MVS CHAFIO (2003.7.24)** with **NEO-CMC 7050**

The runtime models each generic piece; only the ROM layout lives in
`src/game.c`.

## 68000 program and PVC

| Item | Result |
|---|---|
| P ROM loading | `268-p1cr.p1` at word 0, `268-p2cr.p2` at word 2 (`ROM_LOAD32_WORD_SWAP`) |
| Image size | `$800000`: 1 MB fixed + 7 MB banked |
| Decryption | `pvc_prot_device::mslug5_decrypt_68k()` port, then 16-bit byte swap |
| Verification | Prepared `268-pd.bin` byte-identical to MAME 0.242's `cslot1:maincpu` region |
| Banking | PVC 8 KB RAM at `$2FE000-$2FFFFF`; `$2FFFF0/$2FFFF2` select the 1 MB window |
| Self-test | BIOS RAM test over `$2FE000-$2FFFFF` passes; boot reaches the game |
| Colours | PVC pack/unpack registers at `$1FE0`/`$1FE8` modelled |

## Graphics

| Item | Result |
|---|---|
| C ROMs | 8 x 8 MB, CMC50 key `0x19` |
| Fixed layer | 128 KB extracted from the end of the C data |
| Fixed banking | `NG_FIX_BANK_NONE` (plain 128 KB) |
| Prepared data | P/M1/V match MAME; title, HUD, soldiers, boat, jungle, water and explosions render |
| Rendering | Per-scanline sprites, sticky chains, shrink, 96-per-line limit, fix layer, palettes, raster timer |

## Audio

| Item | Result |
|---|---|
| Z80 | Real M1 driver runs; NMI command/reply latches; 512 KB M1 with NEO-ZMC bank windows |
| YM2610 | FM, SSG, ADPCM-A and ADPCM-B through ymfm, clocked by the Z80 |
| ROM handshake | **Fixed:** switching SM1 -> cart M1 no longer resets the Z80 (matches MAME's `set_use_cart_audio`) |
| Output | `SDL_AudioStream` converts 55,555 Hz to the device rate; 60 ms cushion; no frame dropping |
| Result | Native capture matches the MAME 0.242 timeline: music starts about 17 s and is continuous through the captured Mission 1 session; peak 30,104 |
| Not verified | Subjective mix, physical Deck speakers/headphones |

## Input

Keyboard and SDL2 GameController: D-pad/left stick; Xbox A/B/X/Y = Neo Geo
A/B/C/D; Start; Back = coin; left shoulder = select. Tested through the BIOS
menus and gameplay. Steam Input virtual pads use the same SDL mapping.

## Known gaps

- Full-game completion, every weapon/vehicle/boss/route not tested.
- Cycle-count differences in `--verify` (no state mismatches).
- Physical Steam Deck/controller hardware unavailable.
