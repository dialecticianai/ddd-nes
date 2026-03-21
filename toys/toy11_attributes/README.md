# Attributes (toy11)

Attribute table encoding for multi-palette NES backgrounds.

## Purpose

Validates the NES attribute table: each byte assigns palettes to four 16x16 pixel quadrants within a 32x32 pixel region. Proves 4 independent background palettes can be assigned to different screen regions, and that `assert_nametable` reads attribute bytes correctly at $23C0-$23FF.

## Key API

```
Attribute byte = (BR << 6) | (BL << 4) | (TR << 2) | TL
Address = $23C0 + (tile_row / 4) * 8 + (tile_col / 4)
```

## Core Concepts

- Attribute table is the last 64 bytes of each nametable ($23C0-$23FF)
- Each byte covers 4x4 tiles; 2 bits per 2x2 tile quadrant selects palette 0-3
- 4 BG palettes at $3F00-$3F0F (4 colors each, color 0 shared)
- `assert_nametable` works for both tile data and attribute bytes

## Gotchas

- 16x16 pixel granularity is coarse — can't give adjacent 8x8 tiles different palettes within a quadrant
- Bottom 2 nametable rows (28-29) share attribute bytes with unused rows 30-31
- Metatile systems must align with attribute boundaries for clean color separation

## Quick Test

```bash
cd toys/toy11_attributes && make && prove -v t/
```
