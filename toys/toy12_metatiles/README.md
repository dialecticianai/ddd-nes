# Metatiles (toy12)

2x2 metatile decompression system for NES level data compression.

## Purpose

Validates the standard NES metatile pattern: a ROM table defines 2x2 tile groups with palette assignment, level data stores metatile IDs, and a decompression routine expands them into nametable tiles + attribute bytes. Achieves ~4:1 compression (1 byte → 4 tiles + attribute bits).

## Key API

```
Metatile entry (8 bytes): [TL, TR, BL, BR, palette, pad, pad, pad]
Table index: metatile_id * 8 (3x ASL)
Level data: flat array of metatile IDs (row-major)
```

## Core Concepts

- 8-byte entries for power-of-2 indexing (3 ASL vs multiply-by-5)
- Each metatile = one quadrant of an attribute byte (16x16 = attribute granularity)
- Process metatiles in pairs, pack and write attribute byte every 2 entries
- Decompression writes 4 tiles per metatile: 2 in row N, 2 in row N+1

## Gotchas

- 6502 branch range limit (±127 bytes) — use BEQ/JMP trampoline for long loops
- Attribute packing requires processing metatiles in pairs (odd-count rows need padding)
- 8-byte alignment wastes 3 bytes/entry (768 bytes for 256 metatiles) — acceptable trade-off

## Quick Test

```bash
cd toys/toy12_metatiles && make && prove -v t/
```
