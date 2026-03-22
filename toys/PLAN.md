# Toy Development Plan (V2)

**Created**: October 2025
**Purpose**: Progressive NES development with LLM-driven automated testing
**Strategy**: See `TESTING.md` for complete testing vision

---

## Overview

**Toy philosophy**: One focused subsystem per ROM. Validate with automated play-specs where possible.

**Testing approach** (see `TESTING.md`):
- **Phase 1**: jsnes subset (state assertions: CPU, PPU, OAM, memory)
- **Phase 2**: Extended DSL (cycle counting, frame buffer, pixel assertions)
- **Phase 3**: Human/Mesen2 (complex visual, edge cases, real hardware)

**Status**:
- ✅ toy0_toolchain: Build pipeline validated (Perl tests, automated)
- ✅ toys/debug/0-2: Emulator survey complete (jsnes chosen for Phase 1)
- ✅ TESTING.md: Complete testing strategy defined (14 questions answered)
- ✅ NES::Test Phase 1: Implemented (lib/NES/Test.pm, persistent jsnes harness)
- ✅ toy1_sprite_dma: Complete (20/20 tests passing, 45 min, OAM DMA validated)
- ✅ toy2_ppu_init: Complete (5/5 tests passing, 30 min, PPU warmup validated)
- ✅ toy3_controller: Partial (2/2 tests passing, 6 skipped, timeboxed)
- ✅ toy4_nmi: Complete (18/18 tests passing, 45 min, NMI handler + integration)
- ✅ toy5_scrolling: Complete (15/15 tests passing, 20 min, PPUSCROLL validated)
- ✅ toy6_audio: Complete (7/7 tests passing, APU pulse channel + FFT validation)
- ✅ toy7_palettes: Complete (15/15 tests passing, palette RAM + jsnes bug fix)
- ✅ toy8_vram_buffer: Complete (52/52 tests passing, VRAM update buffer)
- ✅ toy9_sprite0: Complete (1/1 tests passing, sprite 0 hit detection)
- ⏭️ Next: toy10 (141/141 tests passing - graphics workflow)

---

## Toy Sequence

### Phase 0: Infrastructure ✅

**toy0_toolchain** - Build pipeline
- **Status**: ✅ Complete
- **Validation**: Perl tests (build artifacts)
- **Artifacts**: Makefile, custom nes.cfg, test.pl template
- **Learnings**: `toys/toy0_toolchain/LEARNINGS.md`

**toys/debug/0_survey** - Emulator research
- **Status**: ✅ Complete
- **Result**: jsnes chosen (headless, direct API)
- **Learnings**: `toys/debug/0_survey/LEARNINGS.md`

**toys/debug/1_jsnes_wrapper** - Headless testing prototype
- **Status**: ✅ Complete
- **Result**: 16 tests passing, JSON output
- **Learnings**: `toys/debug/1_jsnes_wrapper/LEARNINGS.md`

**toys/debug/2_tetanes** - Alternative investigation
- **Status**: ✅ Complete (rejected - API too limited)
- **Learnings**: `toys/debug/2_tetanes/LEARNINGS.md`

---

### Phase 1: Core Subsystems (jsnes validation)

**toy1_sprite_dma** - OAM DMA and sprite display ✅
- **Status**: Complete (20/20 tests passing, 45 min actual vs 2-3hr estimated)
- **Focus**: Sprite DMA timing, OAM update, sprite rendering
- **Key findings**:
  - OAM DMA works perfectly (writing #$02 to $4014 triggers shadow OAM → PPU OAM)
  - jsnes accurately emulates DMA (all 4 test sprites transferred correctly)
  - Frame 1+ for observable state (critical discovery - frame 0 mid-reset)
  - NES::Test Phase 1 validated for hardware validation
- **Play-spec** (actual):
  ```perl
  at_frame 1 => sub {
      assert_ram 0x0200 => 100;  # Shadow OAM
  };
  at_frame 2 => sub {
      assert_sprite 0, y => 100, tile => 0x42, attr => 0x01, x => 80;
      assert_sprite 1, y => 110, tile => 0x43, attr => 0x02, x => 90;
      # ... sprites 2-3
  };
  ```
- **Phase 2 upgrade**: Add `assert_routine_cycles 'oam_dma' => 513`
- **Phase 3 validation**: Visual sprite display in Mesen2 (deferred)
- **Questions answered**: Q1.4 (basic - state inspection works), Q6.2 (partial)
- **Learnings**: `toys/toy1_sprite_dma/LEARNINGS.md`

**toy2_ppu_init** - PPU initialization and vblank ✅
- **Status**: Complete (5/5 tests passing, 30 min actual vs 1-2hr estimated)
- **Focus**: PPU warmup, vblank detection, rendering enable
- **Key findings**:
  - PPU 2-vblank warmup works exactly as documented
  - BIT $2002 / BPL pattern reliably detects vblank transitions
  - Frame timing: Frame 1 (reset), Frame 2 (1st vblank), Frame 3 (2nd vblank, ready)
  - **CRITICAL**: NES RAM NOT zero-initialized! (starts at 0xFF, must explicitly init vars)
  - jsnes PPUSTATUS bit 7 accurate, vblank flag toggles correctly
  - Standard init pattern established for all future toys
- **Play-spec** (actual):
  ```perl
  at_frame 1 => sub {
      assert_ppu_ctrl 0x00;
      assert_ppu_mask 0x00;
      assert_ram 0x0010 => 0x00;  # Marker initialized
  };
  at_frame 2 => sub {
      assert_ram 0x0010 => 0x01;  # First vblank complete
  };
  at_frame 3 => sub {
      assert_ram 0x0010 => 0x02;  # Second vblank complete, PPU ready
  };
  ```
- **Phase 2 upgrade**: Measure 29,658 cycle warmup timing
- **Phase 3 validation**: Rendering stability in Mesen2 (deferred)
- **Questions answered**: Q1.4 (partial - frame timing), RAM init lesson learned
- **Learnings**: `toys/toy2_ppu_init/LEARNINGS.md`

**toy3_controller** - Controller input reading
- **Focus**: 3-step controller read, button state validation
- **Play-spec** (Phase 1):
  ```perl
  press_button 'A';
  at_frame 1 => sub {
      assert_ram 0x10 => 0x01;  # A button flag
  };
  press_button 'A+B';
  at_frame 2 => sub {
      assert_ram 0x10 => 0x03;  # A+B flags
  };
  ```
- **Phase 2 upgrade**: Measure controller read cycles, DPCM conflict test
- **Questions answered**: Q1.4 (partial)
- **Updates**: `learnings/input_handling.md`

---

### Phase 1 Remaining: Graphics + Architecture (jsnes, no cycle counting)

**toy10_graphics_workflow** - Asset pipeline end-to-end ✅
- **Status**: Complete (12/12 tests)
- **Questions answered**: Q1.7, Q2.1, Q2.2

**toy11_attributes** - Attribute table and color granularity ✅
- **Status**: Complete (23/23 tests)
- **Questions answered**: Q2.4

**toy12_metatiles** - 2x2 metatile compression
- **Focus**: Metatile table + decompression to nametable/attributes
- **Questions answered**: Q2.3, Q6.7 (partial)

**toy13_unrom** - UNROM bank switching
- **Focus**: Bus conflict handling, fixed bank organization
- **Questions answered**: Q5.4, Q5.5, Q7.1

**toy14_mmc1** - MMC1 interrupt safety
- **Focus**: Reset+save pattern, NMI during bankswitch
- **Questions answered**: Q7.1

**toy15_state_machine** - Game state transitions
- **Focus**: Menu → gameplay → pause flow
- **Questions answered**: Q4.1, Q6.3

**toy16_entities** - Entity/sprite management
- **Focus**: Array of structs, pool allocation, sprite updates
- **Questions answered**: Q4.2, Q6.4

**toy17_collision** - AABB collision detection
- **Focus**: Bounding box collision
- **Questions answered**: Q4.3, Q4.4 (partial)

---

### Phase 2: Extended DSL (cycle counting + frame buffer required)

_These toys are deferred until Phase 2 DSL is implemented._

**Scrolling** - Nametable streaming (needs vblank cycle budget validation)
- **Questions answered**: Q4.5, Q4.6, Q6.1

**CHR-RAM** - CHR-RAM copy performance (needs cycle counting)
- **Questions answered**: Q2.5, Q7.2

**Audio** - FamiTone2 integration (needs cycle budget measurement)
- **Questions answered**: Q3.2, Q3.3, Q3.5, Q3.6

**Compression** - RLE/LZ decompression benchmarks
- **Questions answered**: Q6.7, Q6.1

**Math** - Multiply/divide vs lookup tables
- **Questions answered**: Q6.6

**Entity/collision upgrades** - Cycle cost measurement for entities + collision

---

## Validation Phase Summary

### Phase 1: jsnes (18 toys — 12 complete, 6 remaining)
- ✅ toy0-9: Infrastructure + core subsystems (toolchain, sprites, PPU, controller, NMI, scrolling, audio, palettes, VRAM buffer, sprite 0)
- ✅ toy10-11: Graphics pipeline + attributes
- ⏭️ toy12: metatiles, toy13: UNROM, toy14: MMC1, toy15: state machine, toy16: entities, toy17: collision

### Phase 2: Extended DSL (deferred — need cycle counting/frame buffer)
- Scrolling, CHR-RAM, audio integration, compression, math benchmarks
- Entity/collision cycle upgrades

### Phase 3: Human/Mesen2 (all toys - visual/edge cases)
- Visual appearance validation
- Edge case debugging
- Real hardware testing (deferred until late)

---

## Implementation Plan

### Immediate (Next Session)

**Step 1: Implement `NES::Test` Phase 1**
- Location: `lib/NES/Test.pm` (new)
- Backend: jsnes wrapper (reuse toys/debug/1_jsnes_wrapper)
- DSL primitives:
  - `load_rom`, `at_frame`, `press_button`, `run_frames`
  - `assert_ram`, `assert_cpu_pc`, `assert_sprite`, `assert_ppu`
  - `assert_tile`, `assert_palette` (if jsnes supports)
- Test infrastructure: Perl module + Test::More integration

**Step 2: Retrofit toy0 with play-spec**
- Create `toys/toy0_toolchain/play-spec.pl`
- Validate basic DSL workflow
- Document pattern in TOY_DEV.md

**Step 3: Build toy1_sprite_dma**
- First toy with automated hardware validation
- Play-spec validates OAM DMA, sprite rendering
- Update `learnings/sprite_techniques.md` with findings

### Medium-Term (After toy1-5 complete)

**Evaluate Phase 1 limits:**
- Which toys blocked without cycle counting?
- Which toys blocked without frame buffer?
- Prioritize Phase 2 features based on actual need

**Implement Phase 2 DSL:**
- Choose emulator backend (FCEUX Lua? TetaNES fork? Other?)
- Add cycle counting: `assert_vblank_cycles_lt`, `assert_routine_cycles`
- Add frame buffer: `assert_pixel`, `assert_framebuffer_matches`
- Upgrade toys 6-8, 13-16 with Phase 2 assertions

### Long-Term (After toy16)

**Revisit deferred questions:**
- Audio assertions (Q5 from TESTING.md)
- TAS format import/export (Q9 from TESTING.md)
- Real hardware testing (Q7.3, Q7.4 from old plan)

**Game prototype:**
- Apply validated patterns to main game
- Write SPEC.md (game design)
- LLM generates play-specs from SPEC.md
- Iterate: play-spec → assembly → validation

---

## Question Coverage Map

**From `learnings/.ddd/5_open_questions.md`** (43 questions total):

**Toolchain (8 questions)**:
- ✅ Q1.1, Q1.2, Q1.3, Q1.6: toy0_toolchain
- toy1, toy3: Q1.4 (cycle counting - Phase 2)
- ✅ Q1.7: toy10 (graphics tools)
- Deferred: Q1.5 (blargg tests), Q1.8 (audio - Phase 2)

**Graphics (5 questions)**:
- ✅ Q2.1, Q2.2: toy10 (asset workflow, palettes)
- ✅ Q2.4: toy11 (attributes)
- toy12: Q2.3 (metatiles)
- Phase 2: Q2.5 (CHR-RAM vs CHR-ROM)

**Audio (6 questions)**:
- ✅ Q3.1, Q3.4: Answered in `learnings/audio.md`
- Phase 2: Q3.2, Q3.3, Q3.5, Q3.6

**Game Architecture (7 questions)**:
- toy15: Q4.1 (state machine)
- toy16: Q4.2 (entities)
- toy17: Q4.3, Q4.4 (collision)
- Phase 2: Q4.5, Q4.6 (scrolling)
- Implicit: Q4.7 (code organization)

**Mappers (6 questions)**:
- ✅ Q5.1, Q5.3: Answered in `learnings/mappers.md`
- Deferred: Q5.2 (needs SPEC.md game genre)
- toy13: Q5.4, Q5.5 (UNROM)
- toy14: Q5.6 (MMC1)

**Optimization (6 questions)**:
- ✅ Q6.5: Answered in `learnings/optimization.md`
- Phase 2: Q6.1, Q6.2 (profiling workflow)
- toy15: Q6.3, Q6.4 (zero page allocation)
- Phase 2: Q6.6 (math benchmarks), Q6.7 (compression)

**Testing (4 questions)**:
- toy13, toy14: Q7.1 (bank switch testing)
- Phase 2: Q7.2 (CHR-RAM performance)
- Deferred: Q7.3, Q7.4 (real hardware)

---

## Key Differences from V1

**Old plan (PLAN.md + PLAN_DEBUG.md):**
- All toys: Manual Mesen2 validation
- Separate debug infrastructure plan
- "Find headless emulator" goal

**New plan (PLAN_V2):**
- **Progressive automation**: Phase 1 (jsnes) → Phase 2 (extended) → Phase 3 (human)
- **Integrated testing**: Testing strategy in TESTING.md, referenced per toy
- **LLM-first workflow**: Play-specs as executable contracts, not just tests
- **Pragmatic phasing**: Build value with Phase 1, upgrade when limits hit

**Philosophy shift:**
- V1: "Automate validation where possible"
- V2: **"Design testing for LLM development, implement progressively"**

---

## Next Steps

**Completed:**
- ✅ NES::Test Phase 1 implemented (lib/NES/Test.pm, NES::Test::Toy.pm)
- ✅ toy0-9: Core subsystems (toolchain, sprites, PPU, controller, NMI, scrolling, audio, palettes, VRAM buffer, sprite 0)
- ✅ toy10_graphics_workflow (12/12 tests, PNG → CHR-ROM → nametable pipeline)
- ✅ toy11_attributes (23/23 tests, attribute table multi-palette encoding)

**Immediate (Phase 1 remaining):**
1. **toy12_metatiles** - 2x2 metatile decompression (Q2.3)
2. **toy13_unrom** - UNROM bank switching (Q5.4, Q5.5)
3. **toy14_mmc1** - MMC1 interrupt safety (Q5.6, Q7.1)
4. **toy15_state_machine** - Game state transitions (Q4.1, Q6.3)
5. **toy16_entities** - Entity/sprite management (Q4.2, Q6.4)
6. **toy17_collision** - AABB collision detection (Q4.3, Q4.4)

**After Phase 1 complete:**
- Evaluate Phase 1 limitations across all toys
- Decide Phase 2 emulator backend (cycle counting + frame buffer)
- Implement Phase 2 DSL
- Build Phase 2 toys (scrolling, CHR-RAM, audio, compression, math)

**Long-term:**
- Start game prototype with validated patterns

---

**Status: Phase 1 nearing completion.** 12 toys complete (176/176 tests passing, 100%), 6 remaining Phase 1 toys. TDD workflow validated, jsnes accuracy confirmed.
