# SPEC — CHR-RAM Performance

## Purpose

Validate CHR-RAM tile copying from PRG-ROM to pattern table RAM during vblank. Proves we can dynamically load tile graphics at runtime (needed for text, compressed tilesets, runtime composition). Measures copy throughput using Phase 2 cycle counting.

**Axis of complexity**: PPUADDR/PPUDATA tile copy loop + CHR-RAM verification.

## Overview

The ROM declares 0 CHR-ROM banks (enabling CHR-RAM). During init, it copies a set of tile definitions from RODATA in PRG-ROM to CHR-RAM pattern table ($0000+) via PPUADDR/PPUDATA. Then places those tiles in the nametable and enables rendering. Tests verify the tiles appear correctly and frame cycles are in expected range.

## Behavioral Contract

### ROM Structure
- iNES header: mapper 0, 0 CHR-ROM banks (CHR-RAM mode)
- Tile definitions in RODATA segment (PRG-ROM)
- At least 4 tiles (64 bytes) copied to pattern table

### CHR-RAM Copy
- During init (before rendering): set PPUADDR to $0000, copy tile bytes via PPUDATA
- Each tile = 16 sequential PPUDATA writes (auto-increment +1)
- Copy at least 4 distinct tiles to pattern table positions $00-$03

### Nametable Display
- After copying tiles to CHR-RAM, write tile indices to nametable
- Place tiles at known positions for test verification
- Load a palette so tiles are visible

### Cycle Verification
- Frame cycles in normal NTSC range after setup

## Success Criteria

- `make` builds a CHR-RAM ROM (0 CHR banks in header)
- Tiles copied to CHR-RAM render correctly in the nametable
- At least 4 tile positions verified via assert_tile
- Palette verified via assert_palette
- Frame cycles in expected range
- All tests pass with `prove -v t/`

## Out of Scope

- Mid-game dynamic tile swapping (this is init-time copy only)
- Measuring exact per-tile cycle cost (would need NMI-level instrumentation)
- CHR-RAM bank switching (UNROM/MMC1 specific)
- Compression/decompression of tile data
