# Prepare-ROMs.ps1 - build a runtime-ready Metal Slug 5 ROM set from your own dumps.
#
# This script extracts the MAME "mslug5" and "neogeo" sets and runs the
# bundled decrypt tool.  It downloads nothing and contains no ROM data.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\Prepare-ROMs.ps1
#   powershell -ExecutionPolicy Bypass -File .\Prepare-ROMs.ps1 -GameZip C:\path\mslug5.zip -NeoGeoZip C:\path\neogeo.zip

param(
    [string]$GameZip = "",
    [string]$NeoGeoZip = "",
    [string]$OutDir = ""
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $OutDir) { $OutDir = Join-Path $here "roms" }
$src = Join-Path $here "roms-src"

function Ask-Zip($label, $current) {
    if ($current -and (Test-Path $current)) { return (Resolve-Path $current).Path }
    while ($true) {
        $p = Read-Host "Path to $label"
        $p = $p.Trim('"').Trim()
        if (Test-Path $p) { return (Resolve-Path $p).Path }
        Write-Host "Not found: $p" -ForegroundColor Yellow
    }
}

$GameZip = Ask-Zip "mslug5.zip" $GameZip
$NeoGeoZip = Ask-Zip "neogeo.zip" $NeoGeoZip

if (-not (Test-Path (Join-Path $here "mslug5_decrypt.exe"))) {
    throw "mslug5_decrypt.exe is missing from $here"
}

if (Test-Path $src) { Remove-Item -Recurse -Force $src }
New-Item -ItemType Directory -Force $src | Out-Null
New-Item -ItemType Directory -Force $OutDir | Out-Null

# Merged MAME sets put the parent files in a mslug5/ subdirectory.  Extract
# to a scratch folder, find the parent set, and flatten only the files the
# tool needs.  This also works for a non-merged zip with the files at the root.
$gameScratch = Join-Path $src "game"
New-Item -ItemType Directory -Force $gameScratch | Out-Null
Write-Host "Extracting $GameZip"
tar -xf $GameZip -C $gameScratch
if ($LASTEXITCODE -ne 0) { throw "Could not extract mslug5.zip with tar" }
$p1 = Get-ChildItem $gameScratch -Recurse -Filter "268-p1cr.p1" | Select-Object -First 1
if (-not $p1) { throw "268-p1cr.p1 was not found in $GameZip" }
$gameDir = $p1.DirectoryName
$needed = @("268-p1cr.p1", "268-p2cr.p2",
            "268-c1c.c1", "268-c2c.c2", "268-c3c.c3", "268-c4c.c4",
            "268-c5c.c5", "268-c6c.c6", "268-c7c.c7", "268-c8c.c8",
            "268-m1.m1", "268-v1c.v1", "268-v2c.v2")
foreach ($name in $needed) {
    $f = Join-Path $gameDir $name
    if (-not (Test-Path $f)) { throw "$name is missing from the mslug5 set" }
    Copy-Item $f (Join-Path $src $name)
}
Remove-Item -Recurse -Force $gameScratch

Write-Host "Extracting $NeoGeoZip"
tar -xf $NeoGeoZip -C $src
if ($LASTEXITCODE -ne 0) { throw "Could not extract neogeo.zip with tar" }

Write-Host "Preparing Metal Slug 5 ROMs"
& (Join-Path $here "mslug5_decrypt.exe") --rom-path $src --out $OutDir
if ($LASTEXITCODE -ne 0) { throw "mslug5_decrypt failed" }

Write-Host ""
Write-Host "Done. Run:" -ForegroundColor Green
Write-Host "  .\`"Metal Slug 5.exe`" --rom-path `"$OutDir`""
