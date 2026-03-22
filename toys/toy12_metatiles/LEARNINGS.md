# LEARNINGS — Metatiles

## Learning Goals

Validate 2x2 metatile decompression: table lookup, nametable writes, attribute byte packing.

### Questions to Answer

1. Can we decompress metatiles and verify via test harness?
2. What's a practical metatile table format?
3. How does decompression interact with the attribute table?
4. What compression ratio does the system achieve?

### Cross-References

- `learnings/graphics_techniques.md` — Metatile system description
- `learnings/.ddd/5_open_questions.md` — Q2.3
- `toys/toy10_graphics_workflow/` — CHR-ROM pipeline
- `toys/toy11_attributes/` — Attribute table encoding

## Findings

**Duration**: ~20 min | **Status**: Complete | **Result**: 24/24 tests passing

### Q1: Decompression + test harness

**Answer**: Yes — `assert_tile` verifies all 16 decompressed tile positions correctly, `assert_nametable` verifies packed attribute bytes. The decompression loop is straightforward: iterate level data, look up metatile, write 4 tiles + accumulate attribute bits.

### Q2: Metatile table format

**Answer**: 8 bytes per metatile (padded to power of 2) is the right call. Indexing is just `metatile_id * 8` which is 3 ASL instructions. The format:
- Bytes 0-3: TL, TR, BL, BR tile indices
- Byte 4: palette (0-3)
- Bytes 5-7: padding

5-byte compact format would save 3 bytes per entry but requires multiply-by-5 (more complex addressing). Not worth it for a table of 256 entries (768 bytes wasted vs simpler code).

### Q3: Attribute table interaction

**Answer**: Each 2x2 metatile maps to exactly one quadrant of an attribute byte. Two adjacent metatiles share one attribute byte (TL + TR quadrants). The packing is:
- First metatile of pair: palette goes in bits 1-0 (no shift)
- Second metatile of pair: palette goes in bits 3-2 (shift left 2)
- Write attribute byte after every pair

This aligns perfectly with the NES hardware — metatiles at 16x16 pixels match the attribute quadrant size.

### Q4: Compression ratio

**Answer**: 1 byte of level data (metatile ID) produces:
- 4 nametable tile writes (4 bytes of nametable data)
- 0.5 attribute byte writes (2 bits, packed with adjacent metatile)

Effective ratio: **1 byte → 4.5 bytes of PPU data** (4.5:1 compression). For a full screen (15x15 metatiles = 225 bytes of level data → 900 nametable bytes + 64 attribute bytes = 964 bytes of PPU data). That's 4.3:1.

### Technical note: branch range

The decompression loop exceeded the 6502's ±127 byte branch range. Fixed with a `BEQ done / JMP loop` trampoline pattern. This is common for longer 6502 routines — watch for it.

## Patterns for Production

- **8-byte metatile entries** — Power-of-2 alignment for fast indexing (3x ASL)
- **Pair-based attribute packing** — Process metatiles in pairs, write attribute byte every 2 metatiles
- **Row-major level data** — Simple flat array, easy to stream for scrolling
- **BEQ/JMP trampoline** — Standard workaround for 6502 branch range limits
- **Compression ratio ~4:1** — 1 byte level data → ~4 bytes nametable output
