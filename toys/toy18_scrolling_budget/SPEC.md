# SPEC — Scrolling Vblank Budget

## Purpose

Validate that nametable column streaming (30 tiles) + OAM DMA + scroll register updates all fit within the NTSC vblank budget. This is the first Phase 2 toy using cycle counting to verify timing constraints.

**Axis of complexity**: Vblank cycle budget measurement + column streaming + scroll updates.

## Overview

The ROM sets up horizontal scrolling with a scrolling background. Each frame in the NMI handler: OAM DMA, write a column of 30 tiles to the nametable at the current scroll edge, update PPUSCROLL with an incrementing X value. Tests verify tiles appeared correctly AND that the total frame cycle count is within expected bounds.

## Behavioral Contract

### NMI Handler Work
1. OAM DMA ($4014 write, ~514 cycles)
2. Column write: 30 tiles to nametable via PPUADDR/PPUDATA
3. Scroll register update: write X and Y to PPUSCROLL ($2005)
4. PPUCTRL update for nametable select bit

### Scroll Behavior
- X scroll increments by 1 pixel per frame
- When scroll crosses 8-pixel boundary, a new column of tiles is written
- Column written at the leading edge of the scroll (new tiles about to scroll in)

### Nametable Verification
- After a column write frame, verify the 30 tiles are present at the expected nametable column
- Verify tiles at multiple positions in the column (top, middle, bottom)

### Cycle Budget Verification
- Total frame cycles should be ~29,781 (full NTSC frame)
- NMI work is a subset of this — verify indirectly by confirming tiles were written successfully (if they appear, the writes completed before vblank ended)

## Success Criteria

- `make` builds the ROM
- After several frames of scrolling, nametable column has expected tile data
- assert_frame_cycles confirms ~29,781 cycles/frame (frame completes normally)
- At least 3 tile positions verified in the streamed column
- Scroll position changes frame-to-frame (verified via RAM or PPU state)
- All tests pass with `prove -v t/`

## Out of Scope

- Vertical scrolling
- Attribute table updates during scroll (would be next iteration)
- Split-screen effects (sprite 0 hit + mid-frame scroll)
- Bidirectional scrolling
