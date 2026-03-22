# PLAN — Math Routines

## Overview

**Goal**: Validate 8x8 multiply and 8-bit divide routines

**Scope**: Single ROM, init-time computation of 8 test cases, results in RAM

**Methodology**: TDD with Phase 2 tools (assert_ram for results, assert_frame_cycles)

---

## Steps

### Step 1: Build Math ROM

**Goal**: Implement general 8x8 multiply and 8-bit divide, compute test cases.

The multiply routine uses the standard shift-and-add algorithm from learnings/math_routines.md: shift the multiplier right, if carry set add the multiplicand to the high byte, shift the result right. 8 iterations for 8 bits.

The divide routine uses repeated subtraction: subtract divisor from dividend, count iterations until borrow. Quotient = count, remainder = what's left.

Compute 4 multiply and 4 divide test cases, store results at $0300+ and $0310+.

**Success Criteria**:
- `make` builds the ROM
- Results appear in RAM

**Commit**: `feat(math): Step 1 — multiply and divide routines`

---

### Step 2: Automated Tests

**Goal**: Verify all 8 test case results.

Check 8 RAM positions for multiply (4 lo + 4 hi bytes) and 8 for divide (4 quotient + 4 remainder). Verify frame cycles in range.

**Success Criteria**:
- `prove -v t/` passes all tests
- All 16 result bytes verified
- Frame cycles in NTSC range

**Commit**: `feat(math): Step 2 — automated math routine tests`

---

### Step 3: Finalize

**Commit**: `docs(math): complete toy21 with findings`

---

## Risks

1. **Multiply algorithm correctness**: The shift-and-add pattern is well-documented but easy to get wrong with carry flag handling. The learnings doc has the exact implementation.
2. **Divide by zero**: Not tested — would infinite loop. Production code must guard against it.

## Dependencies

- `learnings/math_routines.md` — Reference implementations
- `lib/NES/Test.pm` — assert_ram, assert_frame_cycles
