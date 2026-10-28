# Building Metal Slug 5

> The public source repository omits CMake files. Use the buildable source
> archive Metal-Slug-5-Source-v0.1.0.zip attached to the v0.1.0 release.

## Prerequisites

- Git, CMake 3.21+.
- **Windows:** Visual Studio 2022/2026 with "Desktop development with C++"
  (MSVC x64), SDL2 2.30+ (2.32.10 used here).
- **Linux:** `gcc`, `g++`, `make`, CMake, `libsdl2-dev`.
- Your own unzipped `mslug5` and `neogeo` sets. Nothing derived from them is
  committed.

## Windows

```
cmake -S . -B build-windows -G "Visual Studio 18 2026" -A x64 ^
  -DMSLUG5_ROM_DIR=C:/path/to/unzipped/sets ^
  -DSDL2_DIR=C:/path/to/SDL2-2.32.10/cmake
cmake --build build-windows --config Release --parallel
```

Outputs:

```
build-windows/Release/Metal Slug 5.exe
build-windows/Release/mslug5_decrypt.exe
build-windows/generated/*.c          (ROM-derived, not committed)
build-windows/roms/                  (prepared set)
```

The generated C is large. `CMakeLists.txt` compiles it with `/bigobj;/O1`;
MSVC's /O2 is superlinear on these dispatch functions
(and GCC/Clang at -O3 are too), so the generated C is built at -O1//O1; the 68000 code still runs at full speed. Leave that alone.

Without `MSLUG5_ROM_DIR` the player builds interpreter-only, useful for
checking the board model before recompilation.

## Linux

```
cmake -S . -B build-linux -DCMAKE_BUILD_TYPE=Release \
  -DMSLUG5_ROM_DIR=/path/to/unzipped/sets
cmake --build build-linux --parallel
```

Outputs `build-linux/Metal Slug 5`, `mslug5_decrypt`, `roms/` and
`generated/`.

## Profile and rebuild

```
cmake --build build-linux --target profile
cmake --build build-linux --parallel
```

The first command writes runtime-only entry points into
`build-linux/entries.txt`; the second regenerates the C with them.

## Packaging

- Windows: `powershell -ExecutionPolicy Bypass -File packaging/windows/package-windows.ps1`
- Linux/Steam Deck: `./packaging/appimage/build-appimage.sh /path/to/roms`


