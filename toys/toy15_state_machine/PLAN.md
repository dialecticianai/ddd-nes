# PLAN — State Machine

## Overview

**Goal**: Validate state machine pattern with controller-driven transitions

**Scope**: Single ROM, 3 states, Start button transitions, NMI-driven main loop

**Methodology**: TDD with Phase 1 tools (assert_ram for state, press_button for input)

---

## Steps

### Step 1: Build State Machine ROM

**Goal**: Implement a 3-state machine with NMI-driven controller reading and state dispatch.

Scaffold with new-rom.pl. The NMI handler reads the controller, detects new Start presses (edge detection), and dispatches to state-specific update code. Each state handler checks for Start and transitions accordingly. No graphics needed — pure logic test.

Controller edge detection: compare current buttons with previous frame's buttons to detect new presses (button AND NOT prev_button).

**Success Criteria**:
- `make` builds the ROM
- ROM starts in state 0

**Commit**: `feat(state_machine): Step 1 — 3-state machine with controller transitions`

---

### Step 2: Automated Tests

**Goal**: Verify state transitions via press_button + assert_ram.

Test sequence: verify initial state is 0 (menu), press Start and verify transition to 1 (gameplay), press Start and verify transition to 2 (paused), press Start and verify return to 1 (gameplay). Also verify frame counter increments.

**Success Criteria**:
- `prove -v t/` passes all tests
- At least 4 state assertions (initial + 3 transitions)
- Frame counter verified to increment

**Commit**: `feat(state_machine): Step 2 — automated state transition tests`

---

### Step 3: Finalize

**Commit**: `docs(state_machine): complete toy15 with findings`

---

## Risks

1. **press_button timing**: Need to verify that press_button triggers a new-press detection (edge, not level). If the test harness holds the button across multiple frames, edge detection may not fire on the expected frame.
2. **NMI timing**: State transitions happen in NMI, so we need to advance enough frames for the transition to take effect before asserting.

## Dependencies

- `lib/NES/Test.pm` — press_button, assert_ram (exist)
- toy3_controller findings — controller reading pattern (partial, some tests skipped)
