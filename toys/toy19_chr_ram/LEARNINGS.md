# LEARNINGS — CHR-RAM Performance

## Learning Goals

Validate CHR-RAM tile copying from PRG-ROM to pattern table via PPUADDR/PPUDATA.

### Cross-References

- `learnings/mappers.md` — CHR-ROM vs CHR-RAM
- `learnings/.ddd/5_open_questions.md` — Q2.5, Q7.2

## Findings

**Duration**: ~10 min | **Status**: Complete | **Result**: 11/11 tests passing

### Q2.5: CHR-RAM support in jsnes

**Answer**: Works perfectly. iNES header with CHR count = 0 enables CHR-RAM. Writes to $0000-$1FFF via PPUADDR/PPUDATA are stored and rendered correctly. No special setup needed beyond the header change.

### Q7.2: CHR-RAM copy performance

**Answer**: Init-time copy of 4 tiles (64 bytes) is trivial — completes instantly before rendering starts. The copy loop is simple: set PPUADDR to $0000, write 16 bytes per tile via PPUDATA in a tight loop. Auto-increment +1 handles sequential byte writes within a tile.

For runtime tile swapping (during vblank), the budget is ~1760 cycles after OAM DMA. Each PPUDATA write = ~6 cycles (LDA + STA), so 16 bytes/tile = ~96 cycles, meaning ~18 tiles/frame (288 bytes) is theoretical max. The theory estimate of "10 tiles/frame" in the learnings docs is conservative — we have more headroom.

### nes.cfg for CHR-RAM

**Answer**: Simply remove the CHR memory region and CHARS segment from nes.cfg. The ROM is PRG-only (16KB instead of 24KB). ld65 handles this correctly — no CHR block appended to the file.

## Patterns for Production

- **iNES header**: byte 5 = $00 (0 CHR-ROM banks) enables CHR-RAM
- **nes.cfg**: no CHR MEMORY region, no CHARS segment
- **Tile copy loop**: PPUADDR to $0000+, then 16x PPUDATA per tile (auto-increment +1)
- **Tile definitions in RODATA**: store as byte arrays in PRG-ROM
- **Budget**: ~18 tiles/frame theoretical (during vblank after OAM DMA)
- **Init-time copy**: can copy entire tileset before enabling rendering (no vblank constraint)
