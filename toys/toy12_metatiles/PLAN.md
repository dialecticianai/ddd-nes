# PLAN — Metatiles

## Overview

**Goal**: Validate 2x2 metatile decompression — table lookup, nametable writes, attribute packing

**Scope**: Single ROM with metatile table in RODATA, level data as flat array, decompression routine that writes to nametable + attribute table

**Methodology**: TDD with Phase 1 tools (assert_tile for nametable, assert_nametable for attribute bytes, assert_palette for palettes)

---

## Steps

### Step 1: Build ROM with Metatile Decompression

**Goal**: Define a metatile table, a short level data row, and a decompression routine that expands metatile IDs into nametable tiles and attribute bytes.

Scaffold with new-rom.pl, reuse tiles.png from toy10 for CHR data. Define 4+ metatiles in RODATA (8 bytes each: TL, TR, BL, BR, palette, padding). Define a level row of 4 metatile IDs. Write a decompression routine that iterates through the level data, looks up each metatile, writes 4 tiles to the nametable at the correct positions, and packs the 2-bit palette values into attribute bytes.

The decompression target: a row of 4 metatiles starting at nametable position (0, 0), producing 8 tiles across (4 metatiles x 2 tiles wide) and 2 tiles tall.

Load 4 background palettes so different metatiles can use different palettes visually.

**Success Criteria**:
- `make` builds from full pipeline
- ROM boots and decompresses metatiles to nametable

**Commit**: `feat(metatiles): Step 1 — metatile decompression ROM`

---

### Step 2: Automated Tests

**Goal**: Verify decompressed nametable tiles, attribute bytes, and palettes.

Write tests verifying:
- All 4 metatiles decompressed correctly (16 tile positions: 4 metatiles x 4 tiles each)
- Attribute byte at $23C0 contains correctly packed palette bits from the 4 metatiles
- Background palettes loaded correctly
- A blank position outside the decompressed region is tile $00

**Success Criteria**:
- `prove -v t/` passes all tests
- At least 16 tile assertions across 4 metatiles
- At least 1 attribute byte verified with packed palette values
- Palette assertions for all used palettes

**Commit**: `feat(metatiles): Step 2 — automated decompression tests`

---

### Step 3: Finalize

**Goal**: Document findings, update status, run regression.

Update LEARNINGS.md with metatile format findings, compression ratio observations, and patterns for production. Update STATUS.md.

**Success Criteria**:
- All tests pass
- Full regression suite green
- LEARNINGS.md updated

**Commit**: `docs(metatiles): complete toy12 with findings`

---

## Risks

1. **6502 multiply-by-8**: Need to shift left 3 times (or use lookup table) to index 8-byte metatile entries. Simple enough with ASL.
2. **Attribute packing**: Must correctly combine 4 metatile palette values into one attribute byte. Each metatile occupies one quadrant — the formula from toy11 applies directly.
3. **Nametable address calculation**: Each metatile writes to 2 adjacent tiles in row N and 2 in row N+1 (32 tiles apart). Pointer arithmetic in 6502 requires care.

## Dependencies

- `tools/png2chr.pl` — CHR conversion (from toy10)
- `toys/toy10_graphics_workflow/tiles.png` — Reuse test tileset
- `lib/NES/Test.pm` — assert_tile, assert_nametable, assert_palette
- toy11 findings — Attribute byte encoding formula
