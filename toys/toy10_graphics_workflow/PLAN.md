# PLAN — Graphics Asset Pipeline

## Overview

**Goal**: Build and validate the full PNG → CHR-ROM → nametable display pipeline with automated testing

**Scope**: 4 steps covering tool creation, ROM build, tile display, and test validation

**Priorities**:
1. CHR conversion tool (reusable for all future toys)
2. ROM scaffold with CHR-ROM inclusion
3. Nametable display of custom tiles
4. Automated test validation

**Methodology**: TDD with Phase 1 tools (jsnes + assert_tile/assert_palette)
- Test: Nametable tile indices, palette values
- Skip: Visual appearance, attribute tables, pixel-level assertions
- Commit after each step

---

## Steps

### Step 1: PNG → CHR Conversion Tool

**Goal**: Create a reusable tool that converts a 128x128 indexed PNG (256 tiles, 4 colors) into 8192-byte CHR-ROM binary data.

#### Step 1.a: Research CHR Format

Study the NES CHR tile format: each 8x8 tile is 16 bytes (two 8-byte bitplanes). Pixel values 0-3 are encoded across the two planes. A 128x128 PNG contains 16 columns x 16 rows = 256 tiles, filling one complete pattern table.

#### Step 1.b: Build the Conversion Tool

Create `tools/png2chr.pl` that reads an indexed PNG and outputs raw CHR binary. The tool should validate input dimensions (must be 128x128) and color count (must be 4 or fewer). Use an appropriate Perl image library (GD, Imager, or PNG reader) — pick whatever has the simplest install via Homebrew/CPAN.

#### Step 1.c: Create Test Tileset

Create a minimal `tiles.png` test image — 128x128, 4 indexed colors, with several visually distinct tile patterns (solid fill, diagonal stripe, checkerboard, etc.). This can be generated programmatically by the conversion tool itself (a `--generate-test` flag) or by a separate small script.

**Success Criteria**:
- `tools/png2chr.pl tiles.png tiles.chr` produces an 8192-byte output file
- Tool validates input dimensions and rejects non-128x128 images
- Tool is reusable from any toy directory

**Commit**: `feat(tools): png2chr.pl — PNG to CHR-ROM conversion tool`

---

### Step 2: ROM Scaffold with CHR-ROM

**Goal**: Build a ROM that includes the converted CHR data and displays tiles via nametable.

#### Step 2.a: Scaffold Build Files

Run `new-rom.pl tiles` to generate Makefile, nes.cfg, tiles.s. Modify nes.cfg to include a CHR segment that maps to the pattern table address space. Update the Makefile to run png2chr.pl as a build step before assembly (PNG → .chr → .nes).

#### Step 2.b: Assembly ROM with Palette and Nametable

The ROM should perform standard PPU init (2-vblank warmup), load a 4-color palette to palette RAM ($3F00-$3F03), write specific tile indices to known nametable positions, then enable rendering. Place at least 4 different tiles at documented positions (e.g., tile $01 at col 5 row 3, tile $02 at col 10 row 7, etc.).

**Success Criteria**:
- `make` runs the full pipeline: png2chr → ca65 → ld65 → tiles.nes
- `make clean && make` rebuilds from scratch
- ROM is valid iNES format with CHR-ROM bank

**Commit**: `feat(graphics_workflow): Step 2 — ROM with CHR-ROM from PNG pipeline`

---

### Step 3: Automated Tests

**Goal**: Verify the pipeline output via the test harness.

#### Step 3.a: Nametable Tile Tests

Write tests in `t/01-tiles.t` that load the ROM, advance to a frame after rendering is enabled, and verify tile indices at the known nametable positions using `assert_tile`. Verify at least 3 different tile placements.

#### Step 3.b: Palette Tests

Write tests in `t/02-palette.t` (or same file) verifying the palette values at $3F00-$3F03 match the expected colors using `assert_palette`.

**Success Criteria**:
- `prove -v t/` passes all tests
- At least 3 nametable positions verified with `assert_tile`
- Palette values verified with `assert_palette`

**Commit**: `feat(graphics_workflow): Step 3 — automated tile and palette tests`

---

### Step 4: Finalize

**Goal**: Clean up, document findings, mark complete.

#### Step 4.a: Update LEARNINGS.md

Document the full pipeline workflow, tool usage, gotchas discovered, and patterns for production use.

#### Step 4.b: Update STATUS.md

Add toy10 row to `toys/STATUS.md` with test counts.

**Success Criteria**:
- All tests pass (`prove -v t/`)
- Full regression suite still green (`toys/run-all-tests.pl`)
- LEARNINGS.md updated with findings

**Commit**: `docs(graphics_workflow): complete toy10 with findings`

---

## Risks

1. **PNG library availability**: May need to install a Perl image module (Imager, GD). Fallback: generate .chr directly from a script without PNG input (prove pipeline with hand-crafted binary).
2. **CHR format encoding**: Bitplane encoding is fiddly. If conversion produces garbled tiles, compare against known-good CHR data from another ROM.
3. **jsnes CHR-ROM support**: Need to verify jsnes correctly loads CHR-ROM from iNES format (should work — toy0-9 all use CHR-ROM, but with empty/default tiles).

## Dependencies

- `tools/new-rom.pl` — ROM scaffolding (exists)
- `lib/NES/Test.pm` — test harness with `assert_tile`, `assert_palette` (exists)
- Perl image library — needs investigation/installation (Step 1)
