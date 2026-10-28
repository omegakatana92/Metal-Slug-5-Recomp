#!/usr/bin/env bash
# Build the Metal Slug 5 player and recompiler on Linux.
# Usage: ./packaging/linux/build-linux.sh [ROM_DIR]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ROMS="${1:-$ROOT/roms-src}"
cmake -S "$ROOT" -B "$ROOT/build-linux" -DCMAKE_BUILD_TYPE=Release "-DMSLUG5_ROM_DIR=$ROMS"
cmake --build "$ROOT/build-linux" --parallel "${MSLUG5_JOBS:-4}"
