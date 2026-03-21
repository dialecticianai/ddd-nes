# LEARNINGS — Graphics Asset Pipeline

## Learning Goals

This toy validates the end-to-end graphics asset pipeline: creating tile graphics, converting them to CHR-ROM format, loading them into a ROM, and displaying them via the nametable.

### Questions to Answer

1. **What tools convert PNG images to NES CHR-ROM data?**
2. **Can we verify correct tile data and nametable layout via the test harness?**
3. **What's the minimal workflow from "I have pixel art" to "tiles on screen"?**
4. **How does CHR-ROM data get included in the ROM?**

### Decisions to Make

1. **CHR conversion tool**: Write custom or use existing?
2. **Test tileset design**: What minimal tileset demonstrates the pipeline?
3. **Palette choice**: Which NES colors for the test palette?

### Cross-References

- `learnings/graphics_techniques.md` — Metatile systems, nametable layout, attribute tables
- `learnings/.ddd/5_open_questions.md` — Q1.7 (graphics tools), Q2.1 (pixel editor), Q2.2 (palette design)
- `toys/toy7_palettes/LEARNINGS.md` — Palette RAM behavior validated
- `toys/toy8_vram_buffer/LEARNINGS.md` — VRAM update patterns validated

## Findings

**Duration**: ~30 min | **Status**: Complete | **Result**: 12/12 tests passing

### Q1: PNG → CHR conversion

**Answer**: Built `tools/png2chr.pl` using Perl + Imager library.

**Pipeline**: PNG (128x128, 4 colors) → 8192-byte CHR binary (one pattern table, 256 tiles).

**CHR format**: Each 8x8 tile = 16 bytes. Two bitplanes of 8 bytes each. Plane 0 holds bit 0 of each pixel, plane 1 holds bit 1. Pixels are packed MSB-first (leftmost pixel in bit 7).

**Key detail**: The tool handles both indexed and RGB PNGs — for RGB, it auto-discovers unique colors and maps them to indices 0-3. Validates input is exactly 128x128 and has 4 or fewer colors.

**Bonus**: `--generate-test` flag creates a test tileset with 8 distinct tile patterns (blank, 3 solid fills, checkerboard, diagonal stripes, horizontal stripes, border frame).

### Q2: Test harness verification

**Answer**: Yes — `assert_tile(col, row, expected)` and `assert_palette(addr, expected)` work perfectly for verifying nametable contents and palette assignments. 12 assertions validated across 7 tile placements + 4 palette entries + 1 blank position check.

**Key insight**: Frame 4 is sufficient — PPU init takes 2 vblanks, then nametable writes happen before rendering enable.

### Q3: Minimal workflow

**Answer**: The complete pipeline is:

1. Create 128x128 PNG with 4 indexed colors (or use `--generate-test`)
2. Run `png2chr.pl input.png output.chr` (automated in Makefile)
3. Assembly source uses `.incbin "tiles.chr"` in CHARS segment
4. `nes.cfg` maps CHARS segment to CHR memory region
5. ROM code loads palette to $3F00+, writes tile indices to nametable $2000+
6. Enable rendering

**Makefile dependency chain**: `tiles.png` → `tiles.chr` → `tiles.o` → `tiles.nes`. Change the PNG and `make` rebuilds everything.

### Q4: CHR-ROM inclusion

**Answer**: ca65's `.incbin` directive includes raw binary data. The linker config maps the `CHARS` segment to the `CHR` memory region which gets appended after PRG-ROM in the iNES format.

**nes.cfg pattern**:
- `CHR` memory: `start=$0000, size=$2000, fill=yes`
- `CHARS` segment: `load=CHR, type=ro`

The iNES header byte 5 (`$01`) declares one CHR-ROM bank (8KB).

### Toolchain note: Perl version confusion

**Issue discovered**: cpanm shebang pointed to `/usr/bin/perl` (v5.34 system Perl) while project uses `/opt/homebrew/bin/perl` (v5.40 Homebrew). XS modules compiled for wrong Perl version cause "handshake key mismatch" errors.

**Fix**: Updated cpanm shebang to `/opt/homebrew/bin/perl`, reinstalled Imager.

## Patterns for Production

- **`tools/png2chr.pl`** is reusable for all future toys and the main game
- **Makefile pattern**: PNG → CHR dependency ensures asset rebuild on change
- **`.incbin`** directive for including binary data in ROM
- **nes.cfg CHARS segment** pattern for CHR-ROM mapping
- **Tile index documentation**: Comment tile placements in assembly source (makes tests self-documenting)
