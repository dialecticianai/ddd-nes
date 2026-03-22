# SPEC — Metatiles

## Purpose

Validate a 2x2 metatile decompression system: metatile table in ROM defines 4 tile indices + palette per metatile, level data is a flat array of metatile IDs, decompression writes tiles to the nametable and palette selections to the attribute table. This is the standard NES compression pattern for level/map data.

**Axis of complexity**: Metatile table lookup + nametable/attribute decompression.

## Overview

The ROM defines a metatile table (each entry = 4 tile indices + 2-bit palette selection), a small level map (a row or block of metatile IDs), and a decompression routine that writes the tiles to the nametable and packs palette bits into attribute bytes. Tests verify the resulting nametable and attribute table contents.

Builds on toy10 (CHR pipeline) and toy11 (attribute encoding).

## Data Model

**Metatile table entry** (8 bytes each, padded for easy indexing):
- Byte 0: top-left tile index
- Byte 1: top-right tile index
- Byte 2: bottom-left tile index
- Byte 3: bottom-right tile index
- Byte 4: palette number (0-3)
- Bytes 5-7: padding (unused, reserved)

**Level data**: Flat array of metatile IDs (0-255), row-major order. Each ID indexes into the metatile table.

**Decompression output**:
- Nametable: 4 tile writes per metatile (2 in row N, 2 in row N+1)
- Attribute table: 2-bit palette selection packed into attribute bytes (4 metatiles per attribute byte)

## Behavioral Contract

### Metatile Table
- At least 4 distinct metatiles defined (different tile patterns and palettes)
- Table stored in RODATA segment

### Level Data
- A test level row of at least 4 metatile IDs
- Decompressed to nametable starting at a known position

### Decompression
- Each metatile ID produces 4 correct tile writes in the nametable
- Attribute bytes correctly encode the palette for each metatile's quadrant
- Multiple metatiles in a row produce correct adjacent tile output

### Palettes
- At least 2 background palettes loaded (to prove attribute-based palette selection works)

## Success Criteria

- `make` builds the ROM from the full pipeline
- At least 4 metatiles decompressed and verified via `assert_tile`
- At least 16 tile positions verified (4 per metatile x 4 metatiles)
- At least 1 attribute byte verified to contain correct packed palette bits
- Palette entries verified via `assert_palette`
- All tests pass with `prove -v t/`

## Out of Scope

- Runtime decompression during gameplay (this is load-time only)
- Scrolling + streaming metatile columns
- RLE or further compression of the level data
- Cycle counting of decompression routine (Phase 2)
- Vertical level layouts
