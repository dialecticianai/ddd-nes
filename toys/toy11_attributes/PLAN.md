# PLAN — Attribute Table

## Overview

**Goal**: Validate attribute table encoding and multi-palette background rendering

**Scope**: Single ROM demonstrating 4 palettes assigned to different screen regions via attribute bytes

**Methodology**: TDD with Phase 1 tools (jsnes + assert_nametable for attribute bytes + assert_palette)

---

## Steps

### Step 1: Scaffold and Build ROM

**Goal**: Get a building ROM with CHR data, 4 palettes, tiles in nametable, and attribute bytes written.

Copy the CHR pipeline from toy10 (reuse tiles.png, or symlink). Scaffold with new-rom.pl, update Makefile for CHR build step. Write the assembly to load 4 distinct background palettes, fill a region of the nametable with non-blank tiles (covering at least one full 4x4-tile attribute area), and write attribute bytes to assign different palettes to different quadrants.

For the key test: write one attribute byte where each 2-bit quadrant selects a different palette (0, 1, 2, 3). This proves we understand the bitfield encoding. Write a second attribute byte with a uniform palette to contrast.

**Success Criteria**:
- `make` builds attr.nes from the PNG → CHR → assemble → link pipeline
- ROM boots and displays tiles

**Commit**: `feat(attributes): Step 1 — ROM with multi-palette attribute setup`

---

### Step 2: Automated Tests

**Goal**: Verify attribute bytes, palettes, and tile placements via test harness.

Write tests verifying:
- All 4 background palettes ($3F00-$3F0F) have correct color values
- Attribute byte at the key position encodes all 4 palette quadrants correctly
- A second attribute byte has the expected uniform value
- Tiles are present in the nametable regions covered by the attribute bytes

Use `assert_nametable` to read attribute bytes at $23C0+ addresses and `assert_palette` for palette entries.

**Success Criteria**:
- `prove -v t/` passes all tests
- At least 4 palette assertions (one per palette)
- At least 2 attribute byte assertions
- At least 2 tile placement assertions

**Commit**: `feat(attributes): Step 2 — automated attribute and palette tests`

---

### Step 3: Finalize

**Goal**: Document findings and update status.

Update LEARNINGS.md with findings about attribute encoding, update STATUS.md with test counts, run full regression.

**Success Criteria**:
- All tests pass
- Full regression suite green
- LEARNINGS.md updated

**Commit**: `docs(attributes): complete toy11 with findings`

---

## Risks

1. **assert_nametable range**: Need to verify it supports $23C0-$23FF (attribute table range). If not, may need to add assert_attribute helper to NES::Test.
2. **jsnes attribute accuracy**: Attribute table encoding in jsnes should be accurate but hasn't been tested directly.

## Dependencies

- `tools/png2chr.pl` — CHR conversion (from toy10)
- `toys/toy10_graphics_workflow/tiles.png` — Reuse test tileset
- `lib/NES/Test.pm` — assert_nametable, assert_palette
