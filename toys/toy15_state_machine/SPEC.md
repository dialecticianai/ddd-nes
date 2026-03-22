# SPEC — State Machine

## Purpose

Validate a game state machine pattern: a zero-page byte tracks the current state (menu/gameplay/paused), the NMI-driven main loop dispatches to state handlers, and button presses trigger transitions. Proves we can structure game flow on the NES with automated testing.

**Axis of complexity**: State dispatch + controller-driven transitions.

## Overview

The ROM starts in state 0 (menu). Each NMI increments a frame counter and reads the controller. When Start is pressed: menu→gameplay, gameplay→paused, paused→gameplay. The current state and frame counter are stored in zero page for test harness verification.

## Behavioral Contract

### States
- State 0 (MENU): Initial state after reset
- State 1 (GAMEPLAY): Entered from menu via Start press
- State 2 (PAUSED): Entered from gameplay via Start press; Start returns to gameplay

### Transitions
- Start pressed in MENU → state becomes GAMEPLAY (1)
- Start pressed in GAMEPLAY → state becomes PAUSED (2)
- Start pressed in PAUSED → state becomes GAMEPLAY (1)

### Controller Reading
- Read controller each frame in NMI handler
- Detect new presses (edge detection: current AND NOT previous)
- Store current buttons and previous buttons in ZP

### RAM Layout
- $10: game_state (0=menu, 1=gameplay, 2=paused)
- $11: frame_counter (increments each NMI)
- $12: buttons (current frame)
- $13: buttons_prev (previous frame)

## Success Criteria

- ROM starts in state 0 (menu) at frame 4
- After pressing Start: state transitions to 1 (gameplay)
- After pressing Start again: state transitions to 2 (paused)
- After pressing Start again: state returns to 1 (gameplay)
- Frame counter increments each frame
- All tests pass with `prove -v t/`

## Out of Scope

- Visual feedback per state (no graphics)
- Game over state
- Multiple button combinations
- State-specific NMI behavior (all states share same NMI)
