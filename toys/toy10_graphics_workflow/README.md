# Graphics Workflow (toy10)

End-to-end PNG → CHR-ROM → nametable display pipeline.

## Purpose

Validates the complete graphics asset pipeline: convert a 128x128 indexed PNG into NES CHR-ROM binary, include it in a ROM via `.incbin`, load palette, write tile indices to the nametable, and display. Proves custom tile art can go from image editor to running ROM with `make`.

## Key API

```
tools/png2chr.pl input.png output.chr     # Convert PNG to CHR-ROM binary
tools/png2chr.pl --generate-test out.png  # Generate test tileset
make                                       # Full pipeline: PNG → CHR → NES
```

## Core Concepts

- **CHR format**: 8x8 tile = 16 bytes (two 8-byte bitplanes, MSB-first)
- **128x128 PNG**: 16x16 grid = 256 tiles = one pattern table (4KB, padded to 8KB)
- **nes.cfg**: `CHARS` segment with `load=CHR` maps `.incbin` data to CHR-ROM
- **Makefile deps**: `tiles.png → tiles.chr → tiles.o → tiles.nes`

## Gotchas

- Input PNG must be exactly 128x128 with 4 or fewer unique colors
- RGB PNGs auto-map colors to indices 0-3 (order depends on first pixel encountered)
- Imager Perl module required (`cpanm Imager`) — ensure cpanm uses Homebrew perl
- Pattern table 0 only; pattern table 1 (sprites) left blank

## Quick Test

```bash
cd toys/toy10_graphics_workflow && make && prove -v t/
```
