/*
 * game.c - Metal Slug 5 (MAME set "mslug5", NGM-2680)
 * ROM layout shared by the player and the recompiler.
 *
 * The retail MVS cartridge is the NEO-MVS PROGBK3S / CHAFIO board:
 *   - 8 MB program: 1 MB fixed bank + 7 MB banked image, encrypted by the
 *     NEO-PVC chip
 *   - 64 MB NEO-CMC 7050 encrypted sprite data, with the 128 KB fixed layer
 *     stored at the end of the C data
 *   - CMC50-encrypted 512 KB M1, two NEO-PCM2-scrambled 8 MB V ROMs
 *
 * tools/decrypt.c performs all of that at build time.  This structure names
 * only the runtime-ready files it writes, so the player and the recompiler
 * load the program identically.
 *
 * Banking is NEO-PVC, not the plain 1 MB selector: the game writes a byte
 * address to $2FFFF0/$2FFFF2 inside the chip's 8 KB RAM at $2FE000-$2FFFFF,
 * and the PVC adds the 1 MB fixed-bank base.  The runtime models that chip
 * (NG_PROT_PVC); there is no ng_bank_map.
 */
#include "game.h"

const ng_game_t k_mslug5 = {
    .name = "mslug5",
    .title = "Metal Slug 5",
    .prom_size = 0x800000,           /* 1 MB fixed + 7 MB banked */
    .prom = {
        {"268-pd.bin", 0x000000, 0x000000, 0x800000, 0},  /* decrypted image */
    },
    .crom_size = 0x4000000,          /* 64 MB after pairing */
    .crom_pairs = {
        {"268-c1c.c1", "268-c2c.c2"},
        {"268-c3c.c3", "268-c4c.c4"},
        {"268-c5c.c5", "268-c6c.c6"},
        {"268-c7c.c7", "268-c8c.c8"},
    },
    .srom = "268-s1.s1",             /* 128 KB, extracted from the C data */
    .m1 = "268-m1c.m1",              /* CMC50-decrypted Z80 program */
    .vrom = {"268-v1c.v1", "268-v2c.v2"},
    .fix_bank_type = NG_FIX_BANK_NONE,  /* plain 128 KB fixed layer */
    .bank_map = NULL,
    .bank_write_addr = 0,
    .prot_type = NG_PROT_PVC,
};
