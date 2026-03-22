# Toys Status

**Last updated**: 2026-03-21

## Test Suite: 255/255 passing (100%)

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
| toy13_unrom | 4/4 ✓ | Complete | UNROM mapper 2 bank switching |
| toy14_mmc1 | 4/4 ✓ | Complete | MMC1 mapper 1 serial protocol bank switching |
| toy15_state_machine | 5/5 ✓ | Complete | 3-state game flow with controller edge detection |
| toy16_entities | 38/38 ✓ | Complete | Entity storage + OAM sync (4 entities) |
| toy17_collision | 4/4 ✓ | Complete | AABB collision detection (3 scenarios) |
| debug/0_survey | - | Complete | Emulator research |
| debug/1_jsnes_wrapper | - | Complete | jsnes harness (16 tests) |
| debug/2_tetanes | - | Complete | TetaNES investigation (rejected) |

## Next Candidates

**Phase 2 (deferred — need cycle counting DSL):**
- Scrolling, CHR-RAM, audio integration, compression, math benchmarks
