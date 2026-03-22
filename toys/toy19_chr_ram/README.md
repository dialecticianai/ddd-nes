# CHR-RAM (toy19)

Runtime tile loading from PRG-ROM to pattern table RAM.

## Purpose

Validates CHR-RAM: iNES header with 0 CHR banks enables writable pattern table. CPU copies tile definitions from RODATA to $0000+ via PPUADDR/PPUDATA. Tiles render correctly in the nametable. Proves runtime tile generation is feasible for text, compressed tilesets, and dynamic graphics.

## Key API

```
Copy: PPUADDR=$0000, then 16x PPUDATA per tile (auto-increment +1)
nes.cfg: no CHR memory region (PRG-only ROM)
Header: byte 5 = $00 (0 CHR banks = CHR-RAM)
```

## Core Concepts

- Each tile = 16 bytes (2 bitplanes x 8 rows), stored as byte arrays in RODATA
- Init-time copy: write entire tileset before enabling rendering (no vblank constraint)
- Runtime copy: ~18 tiles/frame during vblank (conservative estimate was 10)
- No CHR segment in nes.cfg — ROM is 16KB instead of 24KB

## Gotchas

- CHR-RAM starts empty (all zeros = blank tiles) — must copy tiles before they're visible
- PPUADDR auto-increment +1 works for sequential tile bytes (don't use +32 mode for tile copy)
- Can't write to CHR-RAM while rendering is enabled (only during vblank or with rendering off)

## Quick Test

```bash
cd toys/toy19_chr_ram && make && prove -v t/
```
