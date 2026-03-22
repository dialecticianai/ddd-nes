# PLAN — MMC1 Bank Switching

## Overview

**Goal**: Validate MMC1 serial write protocol and bank switching in jsnes

**Scope**: Single ROM, 4 banks, UNROM-style mode, same marker verification pattern as toy13

**Methodology**: TDD with Phase 1 tools (assert_ram for marker verification)

---

## Steps

### Step 1: Build Multi-Bank MMC1 ROM

**Goal**: Adapt toy13's multi-bank pattern for MMC1.

Reuse the nes.cfg multi-bank approach from toy13 but change the header to mapper 1. Write the MMC1 initialization (reset mapper, 5-write control register setup), the 5-write PRG bank switch routine, and the marker verification loop. Include reset stubs at the end of each bank per the wiki recommendation for power-on safety.

**Success Criteria**:
- `make` produces a 64KB MMC1 ROM
- inspect-rom.pl shows mapper 1

**Commit**: `feat(mmc1): Step 1 — MMC1 serial protocol bank switching ROM`

---

### Step 2: Automated Tests

**Goal**: Verify bank markers via the same pattern as toy13.

Write tests checking RAM $11-$13 for the correct marker values ($AA, $BB, $CC) after bank switches complete.

**Success Criteria**:
- `prove -v t/` passes all tests
- 3+ RAM assertions verify bank markers

**Commit**: `feat(mmc1): Step 2 — automated bank switch verification`

---

### Step 3: Finalize

**Commit**: `docs(mmc1): complete toy14 with findings`

---

## Risks

1. **jsnes MMC1 serial accuracy**: The 5-write protocol is the main risk. If jsnes doesn't correctly implement the shift register, bank switching will fail silently.
2. **Reset stub complexity**: Placing vector stubs in all banks requires careful nes.cfg setup — each bank needs a small code stub at $xFFA-$xFFF.
3. **Power-on state**: jsnes may or may not emulate the MMC1 power-on quirk. The reset stub pattern handles this regardless.

## Dependencies

- `toys/toy13_unrom/nes.cfg` — Multi-bank linker pattern (adapt for mapper 1)
- `lib/NES/Test.pm` — assert_ram (exists)
