# PLAN — CHR-RAM Performance

## Overview

**Goal**: Validate CHR-RAM tile copy from PRG-ROM and verify rendering

**Scope**: Single ROM, init-time copy of 4+ tiles, nametable display, cycle check

**Methodology**: TDD with Phase 2 tools (assert_tile, assert_palette, assert_frame_cycles)

---

## Steps

### Step 1: Build CHR-RAM ROM

**Goal**: ROM with CHR-RAM that copies tile data from PRG-ROM to pattern table, then displays tiles.

No png2chr needed — define tile patterns as byte arrays in RODATA. The iNES header declares 0 CHR-ROM banks which enables CHR-RAM. During init (after PPU warmup, before rendering), set PPUADDR to $0000 and write 16 bytes per tile via PPUDATA for at least 4 tiles. Then write to the nametable placing those tiles at known positions, load a palette, and enable rendering.

The key difference from CHR-ROM toys: no .incbin for CHARS segment, no CHR memory region in nes.cfg. The ROM is PRG-only.

**Success Criteria**:
- `make` builds a ROM with 0 CHR banks
- Tiles display on screen

**Commit**: `feat(chr_ram): Step 1 — CHR-RAM tile copy and display`

---

### Step 2: Automated Tests

**Goal**: Verify tile data, nametable positions, palette, and cycle budget.

Verify nametable tile positions with assert_tile, palette with assert_palette, and frame cycles with assert_frame_cycles. Also verify that tiles at different positions have different indices (proving multiple tiles were copied).

**Success Criteria**:
- `prove -v t/` passes all tests
- At least 4 tile assertions
- Palette verified
- Frame cycles in NTSC range

**Commit**: `feat(chr_ram): Step 2 — automated CHR-RAM tests`

---

### Step 3: Finalize

**Commit**: `docs(chr_ram): complete toy19 with findings`

---

## Risks

1. **jsnes CHR-RAM support**: Need to verify jsnes treats CHR count=0 as writable RAM, not empty ROM. If it doesn't, writes to $0000-$1FFF will be ignored.
2. **nes.cfg without CHR segment**: Need to verify ld65 produces a valid ROM without a CHR memory region.
3. **Nametable reads**: assert_tile reads from vramMem which includes nametable data. CHR-RAM data is at $0000-$1FFF in vramMem — we could also verify tile pixel data directly if needed.

## Dependencies

- `lib/NES/Test.pm` — assert_tile, assert_palette, assert_frame_cycles
