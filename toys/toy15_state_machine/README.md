# State Machine (toy15)

NMI-driven game state machine with controller-based transitions.

## Purpose

Validates a 3-state game flow pattern (menu/gameplay/paused) driven by Start button presses. Proves NMI-based main loop with controller edge detection works for game state management.

## Key API

```
$10: game_state (0=menu, 1=gameplay, 2=paused)
$11: frame_counter (increments each NMI)
$12: buttons, $13: buttons_prev, $14: buttons_new

Edge detection: EOR prev; AND current → new presses only
Start transitions: menu→gameplay→paused→gameplay→...
```

## Core Concepts

- Single ZP byte for state, CMP/BEQ dispatch (no jump table needed for 3 states)
- NMI handler: increment frame → read controller → detect edges → dispatch
- Button read: strobe $4016, read 8 bits via LSR/ROL loop
- Edge detection: `buttons EOR prev; AND buttons` = newly pressed only

## Gotchas

- Must save/restore A/X/Y in NMI handler (PHA/TXA/PHA/TYA/PHA)
- Edge detection requires storing previous frame's buttons before reading new ones
- `press_button` in test harness holds for exactly 1 frame then releases — matches edge detection perfectly

## Quick Test

```bash
cd toys/toy15_state_machine && make && prove -v t/
```
