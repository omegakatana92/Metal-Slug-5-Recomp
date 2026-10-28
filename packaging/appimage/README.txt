METAL SLUG 5 - Linux x86_64 / Steam Deck AppImage
=================================================

A native static recompilation of Metal Slug 5 for the SNK Neo Geo MVS/AES,
built with neogeorecomp v0.2.0.  The game's Motorola 68000 program is
translated to C ahead of time and runs natively; the Z80 sound driver and
YM2610 are modelled.  No game data is included.

REQUIREMENTS
------------
  * Linux x86_64 (SteamOS 3.x, Ubuntu 22.04+, or similar) with SDL2.
  * Your own legally obtained MAME sets:
      mslug5.zip   the game (268-p1cr.p1, p2cr, c1c-c8c, m1, v1c, v2c)
      neogeo.zip   the system ROMs (sp-s2.sp1, sfix.sfix, sm1.sm1, 000-lo.lo)
    The game and BIOS are not included and are not downloaded.

FIRST RUN
---------
Put the two zip files, unzipped, in a folder and point the player at it:

  ./"Metal Slug 5-SteamDeck-x86_64.AppImage" --rom-path /path/to/unzipped/sets

The AppRun helper also searches, in order:
  <folder containing the AppImage>/roms
  <folder containing the AppImage>/roms/mslug5
  ~/.local/share/mslug5/roms
  ~/Emulation/roms/mslug5
  ~/roms/mslug5
  ~/roms

If the folder contains the original encrypted files (268-p1cr.p1,
268-m1.m1, ...), AppRun decrypts them once into
~/.local/share/mslug5/roms and launches from there.  The original zips
and files are never modified.

CONTROLS
--------
  Keyboard              Neo Geo
  ------------------------------------------------
  Arrow keys            joystick
  Z X C V               A B C D
  5                     coin (P1)
  1 / 2                 start (P1 / P2)
  3                     select
  9                     service
  F2                    test switch
  Esc                   quit
  F11                   toggle fullscreen

  Gamepad (Xbox layout, SDL2 GameController)
  ------------------------------------------------
  D-pad / left stick    joystick
  A B X Y               A B C D
  Start                 start
  Back / View           coin
  Left shoulder         select

STEAM DECK
----------
Launch the AppImage from Desktop Mode or add it to Steam as a non-Steam
game.  AppRun adds --fullscreen unless you pass --scale or --headless.
The window keeps the Neo Geo 4:3 picture with pillarboxing on the 16:10
1280x800 panel; it does not stretch.

Steam Input: use the default "Gamepad with Mouse Trackpad" or any layout
that exposes a standard SDL game controller.  The mapping above follows
the Xbox face-button positions.

OPTIONS
-------
  --rom-path DIR        prepared ROM directory (default: roms)
  --bios-path DIR       directory for the system ROMs (default: ROM path)
  --bios FILE           system ROM (default: sp-s2.sp1)
  --headless            no window; run as fast as possible
  --frames N            stop after N frames
  --screenshot N:FILE   save a frame as PNG (repeatable)
  --input FILE          scripted input
  --interp              run the whole machine in the interpreter
  --verify              replay every native block and compare
  --dump-misses FILE    record entry points that only ran in the interpreter
  --scale N             window scale (default 3)
  --fullscreen          fullscreen, 4:3 pillarboxed
  --mute                no sound
  --wav FILE            write the audio to a WAV file

AUDIO
-----
The real Z80 driver and YM2610 produce music and effects.  The mixer
applies MAME's NeoGeo stereo route (SSG 0.84, FM 0.98).  SDL opens the
device at whatever rate/format it supports and converts through
SDL_AudioStream; the old direct 55,555 Hz queue was silent on devices that
reject that rate and could click on devices that accept it.  The generic
runtime also models the YM2610's high register port and the IRQ mask, and
handles the 32-bit Z80 cycle-counter wrap that occurs after about 18
minutes on Windows.  Continuity is measured; the mix has not been
auditioned by a human in this environment.

KNOWN LIMITATIONS
-----------------
  * Native coverage is measured, not assumed.  See README.md.
  * The full game (every mission, weapon, vehicle, boss and ending) has not
    been exhaustively tested.
  * Physical Steam Deck hardware and a physical controller were not
    available here.  The AppImage was run headless and fullscreen under
    WSL2/Xvfb.
  * The x86_64 build needs an SSE2-capable CPU, as SteamOS does.

LICENSE
-------
The original project code is proposed under PolyForm Noncommercial 1.0.0
(see LICENSES/LICENSE-STATUS.txt; confirmation pending).
neogeorecomp is MIT; Musashi and z80 are MIT; ymfm and the MAME Neo Geo
driver references are BSD-3-Clause; SDL2 is zlib.  See
LICENSES/THIRD_PARTY_NOTICES.txt.  The game ROMs and BIOS are
SNK/Playmore property and are not licensed by this project.
