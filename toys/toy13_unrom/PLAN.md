# PLAN — UNROM Bank Switching

## Overview

**Goal**: Validate UNROM bank switching with multi-bank linker config and bus conflict table

**Scope**: Single ROM with 4 PRG banks, switch through banks 0-2 and verify marker bytes

**Methodology**: TDD with Phase 1 tools (assert_ram for marker verification)

---

## Steps

### Step 1: Build Multi-Bank ROM

**Goal**: Create a 64KB UNROM ROM with correct linker configuration and bank switching.

Write a custom nes.cfg with 4 x 16KB PRG bank memory regions: 3 switchable + 1 fixed. The fixed bank ($C000-$FFFF) contains the reset routine, bankswitch subroutine with bus conflict lookup table, and vectors. Each switchable bank contains a unique marker byte at offset $8000.

The reset code switches to banks 0, 1, 2 in sequence, reads the marker byte from $8000 after each switch, and stores it to RAM ($10, $11, $12). No graphics needed — this is a pure PRG-ROM test.

This is a non-trivial nes.cfg since we need multiple PRG segments mapped to different banks. May need to use ca65's `.segment` with bank attributes or separate memory regions for each bank.

**Success Criteria**:
- `make` produces a 64KB+ UNROM ROM
- inspect-rom.pl shows mapper 2 in header

**Commit**: `feat(unrom): Step 1 — multi-bank UNROM ROM with bank switching`

---

### Step 2: Automated Tests

**Goal**: Verify bank switching worked by checking marker bytes in RAM.

Write tests that load the ROM, advance to a frame where all bank switches have completed, and verify RAM $10 = $AA, $11 = $BB, $12 = $CC. Also verify bank 3 (fixed) code is running by checking that the markers were stored (implicit — if markers are correct, the bankswitch and read logic in the fixed bank works).

**Success Criteria**:
- `prove -v t/` passes all tests
- 3 RAM assertions verify bank markers
- At least 1 additional assertion verifying initial state or fixed bank behavior

**Commit**: `feat(unrom): Step 2 — automated bank switch verification tests`

---

### Step 3: Finalize

**Goal**: Document findings and update status.

**Commit**: `docs(unrom): complete toy13 with findings`

---

## Risks

1. **nes.cfg complexity**: Multi-bank linker configs with ca65/ld65 can be tricky. May need separate MEMORY regions per bank with `fill=yes` to ensure correct ROM layout.
2. **jsnes mapper 2 accuracy**: jsnes has Mappers[2] but we haven't tested it. If bank switching doesn't work in jsnes, we may need to timebox and document.
3. **Bus conflict emulation**: jsnes likely doesn't emulate bus conflicts (most emulators don't). The lookup table pattern should still work but may not be testable as a conflict-prevention mechanism.

## Dependencies

- `lib/NES/Test.pm` — assert_ram (exists)
- `tools/inspect-rom.pl` — ROM header inspection (exists)
- ca65/ld65 — multi-bank linker config support
