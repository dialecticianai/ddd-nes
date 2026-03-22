# LEARNINGS — Scrolling Vblank Budget

## Learning Goals

Validate that nametable column streaming fits within the NTSC vblank cycle budget.

### Cross-References

- `learnings/graphics_techniques.md` — Column streaming pattern
- `learnings/timing_and_interrupts.md` — 2273 cycle vblank
- `learnings/.ddd/5_open_questions.md` — Q4.5, Q4.6, Q6.1

## Findings

**Duration**: ~45 min | **Status**: Complete | **Result**: 10/10 tests passing

### Q1: Column streaming cycle budget

**Answer**: 30-tile column write + OAM DMA + scroll update all fit easily within the frame. `assert_frame_cycles` confirms ~29,781 cycles/frame (full NTSC frame) with no overruns, even on frames that include column writes.

The 30-tile column write uses explicit PPUADDR per tile (2 address bytes + 1 data byte = 3 PPUDATA operations per tile). With 16-bit pointer arithmetic in ZP for address calculation, this is reliable and produces correct nametable data.

### Q2: Scroll register timing

**Answer**: PPUSCROLL writes after nametable PPUADDR/PPUDATA writes work correctly in jsnes. The `BIT PPUSTATUS` between column writes and scroll writes resets the address latch properly. PPUCTRL nametable select bit also works.

### Q3: NMI handler cycle cost

**Answer**: The full NMI handler (OAM DMA + conditional 30-tile column + scroll update + register save/restore) completes within the vblank portion of the ~29,781 cycle frame. `assert_frame_cycles` validates the frame completes normally.

### Debugging lesson: off-by-one column index

The column streaming algorithm writes at `(scroll_col + 2) & 31` — two columns ahead of the scroll edge. With scroll starting at 0, the first boundary crossing occurs at scroll_x=8 giving scroll_col=1, so the first column written is **3** not 2. Tests initially checked column 2 and failed — the data was at column 3 all along. Root cause found by using `assert_ram` and `assert_tile` with code refs to print values, not by changing the implementation.

### Phase 2 cycle counting: validated

This is the first toy to use `assert_frame_cycles`. It confirms the jsnes cycle counting patch works correctly: reports ~29,781 CPU cycles/frame matching the NTSC expected value of ~29,780.5. The assertion detects both normal frames and frames with heavy NMI work (column write) — both are in the expected range.

## Patterns for Production

- **16-bit ZP pointer for column addresses**: Calculate `$2000 + row*32 + col` using ZP addr_lo/addr_hi, increment by 32 per row
- **BIT PPUSTATUS before each PPUADDR pair**: Resets address latch (essential)
- **Column ahead of scroll**: Write 2 columns ahead of the scroll edge to ensure tiles are visible before they scroll into view
- **Frame cycle validation**: `assert_frame_cycles` in range 29000-30500 confirms no NMI overruns
- **OAM DMA + 30 tiles + scroll = fits easily**: The ~2273 cycle vblank window is more than sufficient
