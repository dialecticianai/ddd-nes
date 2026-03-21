# LEARNINGS — Attribute Table

## Learning Goals

This toy validates understanding of the NES attribute table: how palette assignment works at the 16x16 pixel granularity, how to write attribute bytes, and how to verify palette-per-region assignments via the test harness.

### Questions to Answer

1. Does `assert_nametable` work for reading attribute table bytes ($23C0-$23FF)?
2. How does the 2-bit-per-quadrant encoding work in practice?
3. Can we verify that tiles in different attribute regions use different palettes?
4. What are the practical constraints of 16x16 color granularity?

### Cross-References

- `learnings/graphics_techniques.md` — Attribute table layout
- `learnings/.ddd/5_open_questions.md` — Q2.4
- `toys/toy10_graphics_workflow/` — CHR-ROM pipeline (reused)

## Findings

**Duration**: ~15 min | **Status**: Complete | **Result**: 23/23 tests passing

### Q1: assert_nametable for attribute bytes

**Answer**: Yes — `assert_nametable` works directly for attribute table addresses $23C0-$23FF. No new helper needed. The attribute table is just the last 64 bytes of the nametable address space, and the existing assertion reads it correctly.

### Q2: Quadrant encoding in practice

**Answer**: Straightforward once you know the bit layout:

- Bits 1-0: top-left 2x2 tile quadrant
- Bits 3-2: top-right
- Bits 5-4: bottom-left
- Bits 7-6: bottom-right

Formula: `(BR << 6) | (BL << 4) | (TR << 2) | TL`

Verified with `$E4` = all 4 palettes in one byte (%11_10_01_00), and `$AA` = uniform palette 2 (%10_10_10_10). Both read back correctly.

### Q3: Multi-palette verification

**Answer**: Yes — we loaded 4 distinct palettes and confirmed all 16 palette entries ($3F00-$3F0F) via `assert_palette`. The attribute bytes correctly assign different palettes to different quadrants. jsnes handles this accurately.

### Q4: 16x16 granularity constraints

**Answer**: Each attribute byte covers 32x32 pixels (4x4 tiles), with 16x16 pixel (2x2 tile) granularity for palette selection. This means:

- You can't have two adjacent 8x8 tiles within the same 16x16 quadrant using different palettes
- Tile art must be designed with this constraint in mind
- Metatile systems (toy15) should align with attribute boundaries for clean color separation
- The bottom two rows of the nametable (rows 28-29) share attribute bytes with unused row 30-31 space — last row of attribute table is partially wasted

## Patterns for Production

- **`assert_nametable`** reads attribute bytes directly — no new DSL helper needed
- **Attribute byte formula**: `(BR << 6) | (BL << 4) | (TR << 2) | TL`
- **Attribute table address**: $23C0 + (tile_row / 4) * 8 + (tile_col / 4) for nametable 0
- **4 BG palettes** at $3F00-$3F0F (4 colors each, color 0 shared as backdrop)
- **Design rule**: Align metatile/level boundaries with 16x16 pixel attribute grid
