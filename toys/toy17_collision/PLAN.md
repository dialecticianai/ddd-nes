# PLAN — Collision

## Overview

**Goal**: Validate AABB collision detection between two entities using 6502 unsigned math.

**Scope**: Single ROM, 2 entities, 3 test scenarios sequenced by NMI frame counter, no graphics.

**Methodology**: TDD with Phase 1 tools (assert_ram for collision result flags).

---

## Steps

### Step 1: Scaffold and Build Collision ROM

**Goal**: Implement AABB collision check with 3 frame-sequenced scenarios.

Run new-rom.pl to scaffold build files. Add ZEROPAGE segment to nes.cfg. The reset handler initializes entity A at (80, 80) in zero page and sets frame counter and result bytes to zero.

The NMI handler increments the frame counter and dispatches based on its value. Frame 1 sets entity B to (84, 83) and runs the AABB check, storing the result at $10. Frame 2 sets entity B to (200, 200) and stores at $11. Frame 3 sets entity B to (87, 80) and stores at $12. Frames beyond 3 are no-ops.

The AABB subroutine takes entity positions from zero page. For each axis, it subtracts A from B. If the carry is clear (borrow occurred, meaning A > B), it negates by subtracting B from A instead (using EOR + INC or just reversing the operands). Then it compares the absolute difference against 8. If both axes have difference less than 8, it returns with A=1; otherwise A=0.

**Success Criteria**: make builds the ROM without errors.

---

### Step 2: Automated Tests

**Goal**: Verify all 3 collision scenarios produce correct results.

Write t/01-collision.t. Use at_frame 10 (enough NMIs for all 3 scenarios to complete). Assert $10 = 1 (overlapping), $11 = 0 (far apart), $12 = 1 (edge touching). Also verify frame counter has incremented.

**Success Criteria**: prove -v t/ passes all tests.

---

### Step 3: Finalize

Update LEARNINGS.md with findings about AABB on 6502. Write README.md. Update toys/STATUS.md.

---

## Risks

1. **Unsigned subtraction pitfall**: On 6502, SBC with borrow produces a two's complement result when A < operand. Must detect via carry flag and reverse operands rather than trying to negate. Getting the carry logic wrong would invert collision results.

2. **Frame timing**: Scenarios depend on frame_counter reaching 1, 2, 3 via NMI. If NMI fires before entity init completes (unlikely with vblank warmup but worth noting), scenario 1 could run with uninitialized entity B.

## Dependencies

- NES/Test.pm: assert_ram, at_frame (both exist)
- toy16_entities findings: entity storage pattern (zero page for 2 entities is simpler than $0300 table)
