# SPEC — Graphics Asset Pipeline

## Purpose

Validate the end-to-end graphics asset pipeline: PNG image → CHR-ROM binary → NES ROM with tiles displayed in the nametable. This toy proves we can create custom tile graphics, convert them to NES format, and display them correctly — the foundation for all visual content.

**Axis of complexity**: Asset conversion + CHR-ROM inclusion + nametable display.

## Overview

The ROM loads custom CHR-ROM tile data (converted from a PNG source image), sets up a palette, writes tile indices to the nametable, and displays the result. The pipeline is automated via Makefile — `make` converts the PNG, assembles the ROM, and produces a playable .nes file.

## Input/Output

**Build-time inputs**:
- `tiles.png` — Source tileset image (128x128 pixels = 16x16 tiles = 256 tiles, indexed 4-color)
- `tiles.s` — Assembly source (nametable setup, palette loading)
- `nes.cfg` — Linker config with CHR segment

**Build-time intermediates**:
- `tiles.chr` — Converted CHR-ROM binary (8192 bytes for one pattern table)

**Build-time outputs**:
- `tiles.nes` — Complete iNES ROM with embedded CHR-ROM

**Runtime behavior**:
1. Standard PPU init (2-vblank warmup)
2. Load palette (4 colors: background + 3 foreground)
3. Write tile indices to nametable (place specific tiles at known positions)
4. Enable rendering
5. Display static screen (no animation, no input)

## Behavioral Contract

### Palette Setup
- Background palette 0 loaded to $3F00-$3F03
- At least 4 distinct colors assigned

### Nametable Layout
- Specific tiles placed at known (col, row) positions in nametable $2000
- At least 4 different tile indices used (proving CHR data has multiple distinct tiles)
- Tile placements documented in assembly source for test reference

### CHR-ROM
- Pattern table 0 ($0000-$0FFF) contains converted tile data from PNG
- At least 4 visually distinct tiles present (not all blank or identical)

## Success Criteria

- `make` produces `tiles.nes` from `tiles.png` + `tiles.s` (full pipeline automated)
- `make clean && make` rebuilds cleanly (no stale artifacts)
- Tile at nametable position (5, 3) contains expected tile index (verified via `assert_tile`)
- Tile at nametable position (10, 7) contains a different expected tile index
- Palette at $3F00-$3F03 contains expected color values (verified via `assert_palette`)
- At least 3 distinct tile placements verified in different nametable positions
- PNG → CHR conversion tool exists and is reusable (`tools/png2chr.pl` or equivalent)

## Out of Scope

- Attribute table setup (toy11_attributes)
- Multiple palettes
- Animation or scrolling
- Sprite graphics (CHR for backgrounds only)
- Metatile systems (toy15_metatiles)
- CHR-RAM (this toy uses CHR-ROM)
