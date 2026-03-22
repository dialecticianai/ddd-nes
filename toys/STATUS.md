# Toys Status

**Last updated**: 2026-03-21

## Test Suite: 200/200 passing (100%)

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
| toy11_attributes | 23/23 ✓ | Complete | Attribute table multi-palette encoding |
| toy12_metatiles | 24/24 ✓ | Complete | 2x2 metatile decompression (~4:1 compression) |
| debug/0_survey | - | Complete | Emulator research |
| debug/1_jsnes_wrapper | - | Complete | jsnes harness (16 tests) |
| debug/2_tetanes | - | Complete | TetaNES investigation (rejected) |

## Next Candidates (Phase 1 remaining)

1. **toy12_metatiles** - 2x2 metatile compression/decompression
2. **toy13_unrom** - UNROM bank switching
3. **toy14_mmc1** - MMC1 interrupt safety
4. **toy15_state_machine** - Game state transitions
5. **toy16_entities** - Entity/sprite management
6. **toy17_collision** - AABB collision detection
