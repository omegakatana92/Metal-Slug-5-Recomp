# Steam Deck / Linux notes - Metal Slug 5

The Steam Deck deliverable is a native Linux x86_64 AppImage. It is built from
the same generated C and runtime as the Windows executable; it is not a
renamed Windows binary and it does not contain an emulator frontend.

## Layout

```
Metal Slug 5.AppDir/
  AppRun
  mslug5.desktop
  mslug5.png
  usr/bin/MetalSlug5
  usr/bin/mslug5_decrypt
  usr/lib/libSDL2-2.0.so.0
  usr/share/applications/mslug5.desktop
  usr/share/icons/hicolor/256x256/apps/mslug5.png
  usr/share/doc/mslug5/{README,LICENSE,LICENSES,docs}
```

`AppRun` sets `LD_LIBRARY_PATH`, enables SDL background joystick events, finds
a prepared ROM directory (or decrypts an encrypted one once into
`~/.local/share/mslug5/roms`), and adds `--fullscreen` unless the user passed
`--headless`, `--scale` or `--fullscreen`.

## Presentation

The game is 320x224. `window_sdl.c` fits the 4:3 picture into the 1280x800
16:10 panel and pillarboxes; it never stretches. F11 toggles fullscreen.

## Controls

D-pad/left stick; **A B X Y** (Xbox positions) = Neo Geo A/B/C/D; Start;
Back/View = coin; left shoulder = select; Esc quits. Steam Input's default
gamepad layout produces a standard SDL controller, so no custom layout is
required. The mapping is fixed in this version.

## Build and test

```
./packaging/appimage/build-appimage.sh /path/to/roms
APPIMAGE_EXTRACT_AND_RUN=1 ./dist/steamdeck/Metal\ Slug\ 5-SteamDeck-x86_64.AppImage \
  --headless --frames 300 --rom-path /path/to/prepared/roms
```

The AppImage was launched headless and fullscreen under WSL2 + Xvfb and exited
0. `ldd` on the staged binary resolves SDL2 from the bundled `usr/lib` and the
usual glibc/X11/Wayland/audio set.

## Not verified

- Physical Steam Deck LCD/OLED, SteamOS Gaming Mode, Steam Input hardware.
- Real speakers/headphones.
- Suspend/resume and Steam overlay behavior.

Do not treat the WSL2/Xvfb launch as proof of physical Deck compatibility.
