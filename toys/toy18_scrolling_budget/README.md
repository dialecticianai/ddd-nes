# Scrolling Budget (toy18)

Horizontal scrolling with NMI column streaming, validated by Phase 2 cycle counting.

## Purpose

First Phase 2 toy. Validates that OAM DMA + 30-tile nametable column write + PPUSCROLL update all fit within the NTSC vblank budget (~2273 cycles). Uses `assert_frame_cycles` to verify frame timing.

## Key API

```
NMI handler: OAM DMA → column write (if boundary crossed) → scroll update
Column: 30 tiles via explicit PPUADDR per tile, 16-bit ZP pointer, +32 per row
Cycle check: assert_frame_cycles sub { $_ > 29000 && $_ < 30500 }
```

## Core Concepts

- Scroll X increments 1 pixel/frame; column written when 8-pixel boundary crossed
- Column position = `(scroll_x/8 + 2) & 31` (2 ahead of scroll edge)
- 16-bit address pointer in ZP: `$2000 + row*32 + col`, increment by 32 each row
- `BIT PPUSTATUS` before each PPUADDR pair resets the address latch
- `assert_frame_cycles` validates ~29,781 cycles/frame (NTSC)

## Gotchas

- First written column is **3** not 2 (scroll starts at 0, first crossing at scroll_x=8 gives col 1+2=3)
- Must reset PPUSTATUS latch between nametable writes and scroll writes
- Frame cycle count is the full frame (~29,781), not just vblank — use tile verification to confirm vblank writes completed

## Quick Test

```bash
cd toys/toy18_scrolling_budget && make && prove -v t/
```
