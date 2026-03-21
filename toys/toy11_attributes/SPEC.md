# SPEC — Attribute Table

## Purpose

Validate attribute table behavior: writing attribute bytes to assign different palettes to different 16x16 pixel regions of the background. This toy proves we understand the 2-bit-per-quadrant encoding and can programmatically control which palette each screen region uses.

**Axis of complexity**: Attribute byte encoding + multi-palette background display.

## Overview

The ROM loads 4 distinct background palettes, places tiles in specific nametable regions, and writes attribute bytes to assign different palettes to different quadrants. Tests verify both the attribute byte values and the palette contents.

Builds on toy10 (CHR-ROM pipeline) — reuses the same tiles.png and png2chr.pl workflow.

## Input/Output

**Runtime behavior**:
1. Standard PPU init (2-vblank warmup)
2. Load 4 background palettes ($3F00-$3F0F)
3. Fill a region of the nametable with non-blank tiles
4. Write attribute bytes to assign palettes 0-3 to different quadrants
5. Enable rendering, display static screen

## Behavioral Contract

### Palette Setup
- 4 background palettes loaded ($3F00-$3F0F)
- Each palette has visually distinct colors (provable via assert_palette)
- Palette 0-3 assigned to different screen regions via attribute table

### Attribute Table
- At least 2 attribute bytes written with different values
- One attribute byte demonstrates all 4 quadrant fields (palettes 0-3 in one byte)
- Attribute byte values are the bitwise combination: `(BR << 6) | (BL << 4) | (TR << 2) | TL`

### Nametable
- Non-blank tiles placed in regions covered by the written attribute bytes
- Tiles exist in all 4 quadrants of at least one attribute byte

## Success Criteria

- `make` produces `attr.nes` from the full pipeline
- All 4 palettes verified at $3F00-$3F0F via `assert_palette`
- At least 2 attribute bytes verified at $23C0+ via `assert_nametable`
- One attribute byte verified to encode all 4 palette selections (palettes 0, 1, 2, 3)
- Tiles verified present in the covered nametable regions
- All tests pass with `prove -v t/`

## Out of Scope

- Mid-frame palette changes (raster effects)
- Scrolling + attribute updates
- Attribute table for sprite palettes (sprites use OAM attribute bits)
- Metatile systems (toy15)
