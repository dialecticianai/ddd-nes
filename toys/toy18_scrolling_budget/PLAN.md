# PLAN — Scrolling Vblank Budget

## Overview

**Goal**: Validate column streaming + OAM DMA + scroll updates fit in vblank, using Phase 2 cycle counting

**Scope**: Single ROM with horizontal scrolling, column streaming in NMI, cycle measurement

**Methodology**: TDD with Phase 2 tools (assert_tile for nametable, assert_frame_cycles for budget, assert_ram for scroll state)

---

## Steps

### Step 1: Build Scrolling ROM

**Goal**: Implement horizontal scrolling with NMI-driven column streaming.

Scaffold with new-rom.pl, reuse tiles.png for CHR data. The ROM initializes with a static background (fill nametable with tile patterns), then enters a scroll loop. Each NMI: OAM DMA, increment scroll X by 1, and when scroll crosses an 8-pixel boundary write a column of 30 tiles to the nametable at the leading scroll edge.

For the column write, use PPUCTRL address increment mode (bit 2 = 1 for +32 per write, which writes vertically down a column). Set PPUADDR to the column's top tile, then write 30 PPUDATA values sequentially — the auto-increment handles the row advance.

Store scroll_x in zero page for test harness verification. Store a "columns_written" counter to track how many column updates have occurred.

**Success Criteria**:
- `make` builds the ROM with CHR pipeline
- ROM scrolls horizontally

**Commit**: `feat(scrolling_budget): Step 1 — horizontal scrolling with column streaming`

---

### Step 2: Automated Tests

**Goal**: Verify column data, scroll state, and cycle budget.

Advance enough frames for at least one column write to occur (9+ frames for first 8-pixel boundary crossing). Verify:
- Scroll X has advanced (RAM check)
- At least one column has been written (columns_written counter > 0)
- Tile data at the written column position is correct (assert_tile)
- Frame cycles are in expected range (~29,781 per frame, confirming no hangs or overruns)

**Success Criteria**:
- `prove -v t/` passes all tests
- At least 3 tile verifications in the streamed column
- Frame cycle count verified
- Scroll state verified via RAM

**Commit**: `feat(scrolling_budget): Step 2 — column streaming + cycle budget tests`

---

### Step 3: Finalize

**Commit**: `docs(scrolling_budget): complete toy18 with findings`

---

## Risks

1. **PPUCTRL increment mode**: Setting bit 2 of PPUCTRL changes address increment to +32 (column mode). Must restore to +1 after column write for subsequent horizontal nametable access. Need to verify jsnes handles this correctly.
2. **Scroll register timing**: PPUSCROLL writes interact with PPUADDR — must write scroll AFTER nametable updates, and reset the address latch with a PPUSTATUS read first.
3. **Nametable mirroring**: With horizontal mirroring, nametables 0 and 1 share the same vertical space but different horizontal space. Need to handle which nametable the column goes to based on scroll position.

## Dependencies

- `tools/png2chr.pl` — CHR conversion
- `lib/NES/Test.pm` — assert_tile, assert_ram, assert_frame_cycles (Phase 2!)
- toy5_scrolling findings — basic PPUSCROLL usage
- toy8_vram_buffer findings — VRAM write patterns
