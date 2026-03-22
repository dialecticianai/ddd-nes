# Open Questions — Consolidated from All Study Phases

**Created**: October 2025
**Purpose**: Central tracking of all open questions raised during systematic wiki study (Phases 0-4)
**Status**: Ready for practical work to answer these through test ROMs and implementation

---

## Quick Summary

**Study complete**: 52/100+ wiki pages (all core priorities)
**Open questions**: 12 practical implementation questions
**Answered/decided**: 31 questions (Phase 1 + Phase 2 complete)
**Primary blockers**: None - Phase 2 DSL (cycle counting) operational

**Categories**:
1. Toolchain & Development Workflow (7 open, **1 answered**)
2. Graphics Asset Pipeline (0 open, **5 answered**)
3. Audio Implementation (1 open, **5 answered**)
4. Game Architecture & Patterns (1 open, **6 answered**)
5. Mapper Selection & Implementation (1 open, **5 answered**)
6. Optimization & Performance (1 open, **6 answered**)
7. Testing & Validation (2 open, **2 answered**)

**Total**: 12 open questions, **31 answered/decided** (43 total)

---

## 1. Toolchain & Development Workflow

### Build Pipeline Integration
**Q1.1**: How to integrate asm6f + NEXXT + FamiTracker into single build workflow?
- Makefile? Shell script? Both?
- Auto-convert graphics assets on change?
- How to assemble + link CHR data?
- **Answer via**: Build first test ROM, document actual workflow

**Q1.2**: How to generate symbol files for debugging?
- asm6f flag for symbol output?
- Integration with Mesen debugger?
- **Answer via**: Check asm6f docs, test with Mesen

### Debugging Workflow
**Q1.3**: How to use Mesen debugger effectively?
- Breakpoint strategies (entry points, vblank, specific cycles)?
- Memory watch patterns (what to track)?
- Trace logging for cycle counting?
- **Answer via**: Debug first test ROM in Mesen

**Q1.4**: How to measure actual cycle usage?
- Mesen's cycle counter?
- Manual counting vs profiler?
- Validate vblank budget adherence?
- **Answer via**: Profile test ROM routines (OAM DMA, tile copy, etc.)

### Testing Strategy
**Q1.5**: When to run blargg test ROMs?
- Before first build? After each subsystem? Continuous?
- Which tests are critical (nestest, ppu_vbl_nmi, sprite_hit)?
- **Answer via**: Run full suite before first custom ROM

**Q1.6**: Build automation structure?
- Separate Makefile targets (rom, chr, clean, run)?
- Dependency tracking (rebuild on asset change)?
- **Answer via**: Create Makefile during first build

### ✅ Asset Conversion (ANSWERED)
**Q1.7**: Graphics tools workflow?
- ✅ **ANSWERED**: Custom `tools/png2chr.pl` (Perl + Imager) converts 128x128 indexed PNG → 8KB CHR-ROM binary
  - Source: `toys/toy10_graphics_workflow/LEARNINGS.md`
  - Makefile automates full pipeline: PNG → CHR → assemble → link
  - `--generate-test` flag creates test tileset programmatically
  - NEXXT/YY-CHR not needed for current workflow (generate + convert programmatically)
- **Next step**: Use for all future toys and main game asset pipeline

**Q1.8**: Music data build integration?
- FamiTracker → text2data → .asm workflow?
- Auto-convert on .ftm file change?
- Include in main Makefile?
- **Answer via**: Create first music track, document build steps

---

## 2. Graphics Asset Pipeline

### ✅ Tile Design (ANSWERED)
**Q2.1**: What pixel editor workflow for 4-color constraint?
- ✅ **ANSWERED**: Generate test tilesets programmatically via `png2chr.pl --generate-test`
  - Source: `toys/toy10_graphics_workflow/LEARNINGS.md`
  - For production art: any editor that exports 128x128 indexed PNG (4 colors)
  - png2chr.pl handles both indexed and RGB PNGs (auto-discovers unique colors)
- **Next step**: Use Aseprite or similar for real game art, feed through pipeline

**Q2.2**: Palette design tools/techniques?
- ✅ **ANSWERED**: Pick NES palette indices directly in assembly
  - Source: `toys/toy11_attributes/LEARNINGS.md`
  - 4 BG palettes at $3F00-$3F0F, 4 colors each (color 0 shared as backdrop)
  - Validated: loading all 4 palettes and assigning via attribute table works correctly
- **Next step**: Create NES palette reference chart for art design

### ✅ Metatile Systems (ANSWERED)
**Q2.3**: How to efficiently compress level data with metatiles?
- ✅ **ANSWERED**: 8-byte metatile entries (4 tiles + palette + 3 padding), power-of-2 indexing via 3x ASL
  - Source: `toys/toy12_metatiles/LEARNINGS.md`
  - ~4:1 compression ratio (1 byte level data → 4 nametable tiles + attribute bits)
  - Pair-based attribute packing (write attribute byte every 2 metatiles)
  - 24/24 tests validate full decompression
- **Next step**: Use pattern for main game level data

**Q2.4**: How to handle attribute table granularity (16×16 pixels)?
- ✅ **ANSWERED**: Metatiles align perfectly with attribute quadrants (2x2 tiles = 16x16 pixels)
  - Source: `toys/toy11_attributes/LEARNINGS.md`
  - Each metatile occupies exactly one attribute quadrant
  - Design rule: align metatile/level boundaries with 16x16 pixel attribute grid
  - assert_nametable reads attribute bytes at $23C0-$23FF directly (no new helper needed)
- **Next step**: Accept constraint in art design — no sub-16x16 palette variation

### ✅ CHR Data Management (ANSWERED)
**Q2.5**: When to use CHR-ROM vs CHR-RAM?
- ✅ **ANSWERED**: Both validated — CHR-ROM (toy10) and CHR-RAM (toy19) work in jsnes
  - Source: `toys/toy19_chr_ram/LEARNINGS.md`
  - CHR-RAM: header byte 5 = $00, no CHR segment in nes.cfg, copy tiles via PPUADDR/PPUDATA
  - Runtime budget: ~18 tiles/frame during vblank (better than 10-tile theory estimate)
  - Decision still depends on game genre: CHR-ROM for action, CHR-RAM for text/dynamic
- **Answer via**: Prototype with both in test ROMs

---

## 3. Audio Implementation

### ✅ Sound Engine Integration (ANSWERED)
**Q3.1**: Which sound engine to use?
- ✅ **ANSWERED**: FamiTone2 (beginner-friendly)
  - Source: `learnings/audio.md` - Comparison of 8 engines analyzed
  - Alternative: FamiStudio if rich features needed later
- **Next step**: Integrate FamiTone2 in audio test ROM

**Q3.2**: How to structure SFX vs music priority?
- ✅ **ANSWERED**: Flag-based SFX borrow pattern — SFX takes pulse 2, restores after countdown
  - Source: `toys/toy22_audio_multi/LEARNINGS.md`
  - 3 ZP bytes: sfx_trigger, sfx_active (countdown), sfx_completed
  - NMI checks trigger → borrows channel → counts down → restores
  - No complex priority queue needed for basic games

**Q3.3**: Cycle budget allocation for audio?
- ✅ **ANSWERED**: Negligible NMI overhead for per-frame APU updates
  - Source: `toys/toy22_audio_multi/LEARNINGS.md`
  - assert_frame_cycles shows normal ~29,781 even on SFX trigger frames
  - Simple SFX handler uses ~10 instructions per NMI (far less than FamiTone2's 1000-1500)
  - Generous headroom: OAM DMA + column streaming + audio all fit easily

### ✅ Music Workflow (ANSWERED)
**Q3.4**: Composition tool - FamiTracker vs FamiStudio?
- ✅ **ANSWERED**: FamiTracker (industry standard)
  - Source: `learnings/audio.md` - Well-documented, widely used
  - Alternative: FamiStudio (modern, better UI) if limitations hit
- **Next step**: Install and create test track

**Q3.5**: Asset build integration for music?
- FamiTracker .ftm → text2data → .asm include?
- Auto-rebuild on .ftm change?
- Include music data in which PRG bank?
- **Answer via**: Set up music build pipeline

**Q3.6**: When to implement audio in development?
- Simple beep/bloop in early test ROM?
- Full music integration before game?
- SFX first or music first?
- **Answer via**: Add audio incrementally (beep → SFX → music)

---

## 4. Game Architecture & Patterns

### ✅ State Management (ANSWERED)
**Q4.1**: State machine patterns for game flow?
- ✅ **ANSWERED**: Single ZP byte + CMP/BEQ dispatch in NMI handler
  - Source: `toys/toy15_state_machine/LEARNINGS.md`
  - 3 states (menu/gameplay/paused), Start button transitions
  - Button edge detection: `EOR prev; AND current` (3 instructions)
  - No jump table needed for small state counts (<8)
- **Next step**: Use pattern in main game

**Q4.2**: Entity system for multiple sprites?
- ✅ **ANSWERED**: Array-of-structs, 8-byte stride at $0300+
  - Source: `toys/toy16_entities/LEARNINGS.md`
  - Fields: x, y, tile, attr, type, state, pad, pad
  - 4 entities = 32 bytes, scales to 16 (128 bytes)
  - NMI syncs entity → OAM with field reorder + DMA
  - ZP for counters only, entity data in regular RAM
- **Next step**: Use pattern in main game

### ✅ Collision Detection (ANSWERED)
**Q4.3**: Bounding box collision patterns for 6502?
- ✅ **ANSWERED**: SEC/SBC for difference, carry for sign, EOR/ADC for abs, CMP for threshold
  - Source: `toys/toy17_collision/LEARNINGS.md`
  - ~20 instructions for full 2-axis AABB check
  - 3 scenarios validated: overlap, miss, edge touch
- **Next step**: Use pattern for sprite-sprite collision in game

**Q4.4**: Pixel-perfect collision worth the cycles?
- ✅ **ANSWERED**: No — AABB sufficient for action/platformer games
  - Source: `toys/toy17_collision/LEARNINGS.md`
  - 8x8 boxes match sprite size naturally
  - Pixel-perfect would require CHR-ROM pixel mask reads — vastly more expensive
  - Only consider for puzzle games with irregular shapes

### ✅ Level Streaming (ANSWERED)
**Q4.5**: How to load/unload level data dynamically?
- ✅ **ANSWERED**: Stream columns during scrolling, write to nametable in NMI
  - Source: `toys/toy18_scrolling_budget/LEARNINGS.md`
  - Write 2 columns ahead of scroll edge: `(scroll_x/8 + 2) & 31`
  - 30-tile column write via explicit PPUADDR per tile, 16-bit ZP pointer
  - Fits easily within vblank budget alongside OAM DMA + scroll update

**Q4.6**: Nametable streaming during scrolling?
- ✅ **ANSWERED**: Column-at-a-time for horizontal scrolling, validated with cycle counting
  - Source: `toys/toy18_scrolling_budget/LEARNINGS.md`
  - 30 tiles per column, each tile = BIT PPUSTATUS + 2 PPUADDR + 1 PPUDATA
  - Total column write + OAM DMA + scroll update all fit in ~29,781 cycle frame
  - Phase 2 assert_frame_cycles confirms no overruns

### Code Organization
**Q4.7**: How to structure code for maintainability?
- One file or modular includes?
- Naming conventions (snake_case, PascalCase)?
- Comment density (every line, per-block, minimal)?
- **Answer via**: Establish conventions in first test ROM

---

## 5. Mapper Selection & Implementation

### ✅ Mapper Choice (ANSWERED)
**Q5.1**: Which mapper for ddd-nes?
- ✅ **ANSWERED**: Start NROM, migrate to UNROM when >32KB
  - Source: `learnings/mappers.md` - Mapper progression strategy
  - Move to MMC1 only if need CHR-ROM switching or PRG-RAM
- **Next step**: Prototype in NROM, measure ROM usage to know when to migrate

**Q5.2**: CHR-ROM or CHR-RAM for ddd-nes?
- **Pending**: Wait for SPEC.md (game genre decision)
- Action/platformer → CHR-ROM
- RPG/puzzle → CHR-RAM
- **Answer via**: Define game genre, choose CHR strategy

**Q5.3**: ✅ **ANSWERED**: When to switch mappers?
- ✅ NROM → UNROM: When ROM >32KB or need CHR switching
- ✅ UNROM → MMC1: When need CHR-ROM banks or PRG-RAM
- Source: `learnings/mappers.md` - Mapper decision matrix
- **Next step**: Track ROM growth during development, migrate when thresholds hit

### ✅ UNROM Implementation (ANSWERED)
**Q5.4**: Bus conflict handling in practice?
- ✅ **ANSWERED**: `sta banktable, Y` pattern works (banktable[N] = N in RODATA, fixed bank)
  - Source: `toys/toy13_unrom/LEARNINGS.md`
  - Banktable = N bytes (one per bank, e.g. 4 bytes for 4-bank UNROM)
  - jsnes doesn't emulate bus conflicts but pattern is correct for real hardware
- **Next step**: Use same pattern in main game

**Q5.5**: Fixed bank organization?
- ✅ **ANSWERED**: Fixed bank ($C000-$FFFF) contains: vectors, reset, NMI handler, bankswitch routine + bus conflict table
  - Source: `toys/toy13_unrom/LEARNINGS.md`
  - nes.cfg pattern: separate MEMORY regions per bank, all `file=%O`, same `start=$8000`
  - NMI handler must restore bank: `ldy current_bank; tya; sta banktable, Y`
  - Fixed bank has ~16KB available (minus vectors)
- **Next step**: Add common utils (controller read, OAM DMA) to fixed bank in main game

### ✅ MMC1 Implementation (ANSWERED + VALIDATED)
**Q5.6**: MMC1 interrupt safety - which solution?
- ✅ **ANSWERED + VALIDATED**: Reset + save/restore pattern confirmed in toy14
  - Source: `toys/toy14_mmc1/LEARNINGS.md`
  - Serial protocol works in jsnes (5-write shift register)
  - NMI handler: reset mapper ($80→$8000) + restore bank via serial write
  - nes.cfg identical to UNROM — only iNES header mapper number changes
  - Per-bank reset stubs NOT tested (jsnes initializes correctly without them)

---

## 6. Optimization & Performance

### ✅ When to Optimize (PARTIALLY ANSWERED)
**Q6.1**: Premature vs necessary optimization?
- ✅ **PARTIALLY ANSWERED**: Vblank budget has generous headroom for typical NMI work
  - Source: `toys/toy18_scrolling_budget/LEARNINGS.md`
  - OAM DMA + 30-tile column + scroll update all fit easily in vblank
  - Phase 2 assert_frame_cycles validates no overruns
  - For now: don't optimize unless assert_frame_cycles shows problems
  - Remaining: need to test with heavier NMI loads (full game loop)

**Q6.2**: How to measure actual cycle usage?
- Mesen debugger cycle counter?
- Manual counting from instruction reference?
- **Theory**: `learnings/timing_and_interrupts.md` - Instruction cycle reference provided
- **Answer via**: Use Mesen profiler on test ROM routines (same as Q1.4)

### ✅ Zero Page Allocation (ANSWERED)
**Q6.3**: How to manage 256 bytes of zero page?
- ✅ **ANSWERED**: Reserve $10+ for game variables, group by subsystem
  - Source: `toys/toy15_state_machine/LEARNINGS.md`, `toys/toy16_entities/LEARNINGS.md`
  - Pattern: $10-$14 for state/counters/buttons, $20+ for collision temps
  - Use ca65 `.segment "ZEROPAGE"` with named labels (not magic numbers)
  - Entity data stays in regular RAM ($0300+), only counters in ZP
- **Next step**: Document full ZP allocation map when building main game

**Q6.4**: Which variables deserve zero page?
- ✅ **ANSWERED**: Counters, flags, loop temps, button state — NOT bulk entity data
  - Source: `toys/toy16_entities/LEARNINGS.md`
  - ZP for: game_state, frame_counter, buttons, buttons_prev, collision results
  - Regular RAM for: entity tables, shadow OAM, VRAM buffers
  - Indexed addressing (LDA table,X) works same speed for ZP and RAM
  - ZP is precious (256 bytes) — reserve for frequently-branched-on values and pointers

### ✅ Math Routines (ANSWERED)
**Q6.6**: When to use math routines - cost/benefit?
- ✅ **ANSWERED**: General routines ~200-250 cycles, prefer shifts for constants
  - Source: `toys/toy21_math/LEARNINGS.md`
  - 8x8 multiply: ~200 cycles (shift-and-add), 16-bit result in A:X
  - 8-bit divide: ~250 cycles (restoring division), quotient=A, remainder=Y
  - Powers of 2: 2 cycles/shift (always use ASL/LSR)
  - Known constants: 10-30 cycles (shift+add decomposition)
  - Frequent variable ops: 256-byte lookup table (4-5 cycles/lookup)
  - **Avoid division in game loop** — restructure or multiply by inverse
  - Found and fixed bug in learnings/math_routines.md divide routine

### ✅ Compression (PARTIALLY ANSWERED)
**Q6.7**: Compression decompression cost?
- ✅ **PARTIALLY ANSWERED**: RLE validated — fast, simple, ~40 instructions
  - Source: `toys/toy20_compression/LEARNINGS.md`
  - Bit-7 flag format, 16-bit ZP pointer access pattern
  - Init-time decompression has trivial cycle cost (fraction of one frame)
  - Compression ratio: 1.36:1 on test data, 3:1–10:1 on real level data
  - Limitation: literal bytes $80-$FF can't be used (bit 7 collision)
  - LZ decompression deferred (more complex, not yet needed)

### ✅ Unofficial Opcodes (ANSWERED)
**Q6.5**: Policy on unofficial opcodes?
- ✅ **ANSWERED**: Avoid unless bottleneck proven, document if used
  - Source: `learnings/optimization.md` - Stability issues documented (chip revision differences)
  - Not all stable across NES hardware variants (Dendy, PAL clones)
  - Test coverage required if used
- **Next step**: Benchmark official vs unofficial in test ROM if bottleneck discovered

---

## 7. Testing & Validation

### Bank Switching Tests
**Q7.1**: How to test bank switching?
- Build ROM with code in each bank printing bank number?
- Test all banks accessible?
- Test NMI/IRQ during bankswitch (MMC1)?
- **Answer via**: Create bank switch test ROM

### ✅ CHR-RAM Performance (ANSWERED)
**Q7.2**: What's the actual CHR-RAM copy performance?
- ✅ **ANSWERED**: ~18 tiles/frame during vblank (288 bytes), better than 10-tile estimate
  - Source: `toys/toy19_chr_ram/LEARNINGS.md`
  - Each tile = 16 PPUDATA writes = ~96 cycles
  - ~1760 cycles available after OAM DMA → ~18 tiles max
  - No double-buffering needed for typical use (10-15 tiles/frame is plenty)

### Real Hardware Testing
**Q7.3**: When to test on real hardware?
- After emulator validation?
- Before final release?
- Which flashcart (Everdrive, Powerpak)?
- **Answer via**: Defer until game nearing completion

### Donor Cart Compatibility
**Q7.4**: Which donor carts available for reproduction?
- **UNROM**: Common (Mega Man, Castlevania, Metal Gear)
- **MMC1**: Very common (Metroid, Zelda, Kid Icarus)
- CHR-RAM boards less common?
- **Answer via**: Research donor cart availability when ready for hardware

---

## Next Steps to Answer These Questions

### Phase 1: Toolchain Setup (Answers Q1.1-Q1.8, Q3.4)
1. Install asm6f, Mesen, NEXXT, FamiTracker
2. Run blargg test ROM suite
3. Create build script (Makefile)
4. Document toolchain setup process

### Phase 2: First Test ROM (Answers Q1.3-Q1.6, Q2.1-Q2.2, Q6.3)
1. Build "hello world" NROM ROM
2. Display sprite (test graphics workflow)
3. Read controller (test input)
4. Play beep (test basic audio)
5. Profile cycle usage (measure actual costs)
6. Document findings in learning docs

### Phase 3: Subsystem Test ROMs (Answers Q2.3-Q2.5, Q3.2-Q3.3, Q4.3-Q4.6, Q6.6-Q6.7)
1. Graphics test: Metatiles, attributes, scrolling
2. Audio test: FamiTone2 integration, SFX mixing
3. Collision test: AABB, tile-based, sprite-sprite
4. Scrolling test: Nametable streaming, level data
5. Compression test: RLE/LZ decompression benchmarks
6. Update learning docs with actual measurements

### Phase 4: Mapper Test ROMs (Answers Q5.4-Q5.5, Q7.1-Q7.2)
1. UNROM bank switch test (bus conflict table, fixed bank layout)
2. MMC1 interrupt safety test (reset+save validation)
3. CHR-RAM performance test
4. Compare mappers, document actual ROM usage patterns

### Phase 5: Game Prototype (Answers Q4.1-Q4.7, Q6.1-Q6.4)
1. Define game in SPEC.md (determines Q5.2 CHR choice)
2. Implement core gameplay (state machine, entity system)
3. Measure performance bottlenecks (cycle profiling)
4. Optimize critical paths (zero page allocation, math routines)
5. Document architecture patterns established

---

## Status: Ready for Practical Work

**No blockers**: All questions answerable through test ROM development and iteration.

**Recommended path**: Start with toolchain setup and "hello world" test ROM. Answer questions incrementally as they become relevant.

**Documentation strategy**: Update learning docs with actual measurements and edge cases discovered during implementation.
