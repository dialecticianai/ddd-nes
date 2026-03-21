# Toys Status

**Last updated**: 2026-03-21

## Test Suite: 153/153 passing (100%)

| Toy | Tests | Status | Notes |
|-----|-------|--------|-------|
| toy0_toolchain | 6/6 ✓ | Complete | Build pipeline |
| toy1_sprite_dma | 20/20 ✓ | Complete | OAM DMA |
| toy2_ppu_init | 5/5 ✓ | Complete | 2-vblank warmup |
| toy3_controller | 2/2 ✓ | Partial (timeboxed) | 6 tests skipped |
| toy4_nmi | 18/18 ✓ | Complete | NMI handler + integration |
| toy5_scrolling | 15/15 ✓ | Complete | PPUSCROLL horizontal auto-scroll |
| toy6_audio | 7/7 ✓ | Complete | Pulse channel tone generation + FFT validation |
| toy7_palettes | 15/15 ✓ | Complete | Palette RAM + mirroring + jsnes bug fix |
| toy8_vram_buffer | 52/52 ✓ | Complete | VRAM update buffer |
| toy9_sprite0 | 1/1 ✓ | Complete | Sprite 0 hit detection (play-spec.pl only) |
| toy10_graphics_workflow | 12/12 ✓ | Complete | PNG → CHR-ROM → nametable pipeline |
| debug/0_survey | - | Complete | Emulator research |
| debug/1_jsnes_wrapper | - | Complete | jsnes harness (16 tests) |
| debug/2_tetanes | - | Complete | TetaNES investigation (rejected) |

## Next Candidates

1. **toy10_graphics_workflow** - Asset pipeline end-to-end (PNG → CHR-ROM)
2. **toy11_attributes** - Attribute table and color granularity
3. **toy12_metatiles** - 2x2 metatile compression/decompression
