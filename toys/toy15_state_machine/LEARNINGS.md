# LEARNINGS — State Machine

## Learning Goals

Validate a game state machine with controller-driven transitions on the NES.

### Cross-References

- `learnings/.ddd/5_open_questions.md` — Q4.1 (state machine), Q6.3 (zero page allocation)

## Findings

**Duration**: ~15 min | **Status**: Complete | **Result**: 5/5 tests passing

### Q1: Simplest NES state machine pattern

**Answer**: A single zero-page byte for state ID + conditional branches in the NMI handler. No jump table needed for 3 states — direct CMP/BEQ chains are fast enough and simpler to debug. For more states (8+), a jump table via indexed indirect addressing would be worthwhile.

Pattern: NMI increments frame counter → reads controller → detects new presses → dispatches to state-specific transition logic.

### Q2: Testing state transitions

**Answer**: `press_button 'Start'` + `assert_ram` works perfectly. The button press advances 1 frame, the NMI fires during that frame with the button pressed, edge detection triggers, and the state transitions. Verifiable on the next `at_frame` call.

Key: the edge detection pattern (`buttons EOR prev; AND buttons`) correctly distinguishes new presses from held buttons.

### Q3: Zero page allocation for game state

**Answer**: Compact layout — 5 bytes covers the essentials:
- $10: game_state (single byte, 0-255 states possible)
- $11: frame_counter (wraps at 255, sufficient for timing)
- $12: buttons (packed byte: A=80, B=40, Sel=20, Start=10, U=08, D=04, L=02, R=01)
- $13: buttons_prev (for edge detection)
- $14: buttons_new (current AND NOT prev)

This leaves most of zero page free for game-specific variables.

## Patterns for Production

- **State byte + CMP/BEQ dispatch**: Simple, fast, debuggable for small state counts
- **Button edge detection**: `EOR prev; AND current` detects new presses in 3 instructions
- **NMI-driven main loop**: Frame counter + controller read + state update in NMI handler
- **Register save/restore in NMI**: PHA/TXA/PHA/TYA/PHA at entry, reverse at exit
- **5-byte controller state block**: buttons, prev, new — compact and reusable
