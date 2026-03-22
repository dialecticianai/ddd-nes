# SPEC — Collision

## Purpose

Validate AABB collision detection between two entities using 6502 unsigned arithmetic. Two entities with 8x8 bounding boxes are tested across 3 scenarios: overlapping, far apart, and edge-touching. Results stored in zero page RAM flags.

**Axis of complexity**: Unsigned distance comparison on 6502.

## Overview

The ROM defines two entities (A and B) with X/Y positions. The NMI handler sequences through 3 test scenarios using a frame counter, repositioning entity B each scenario while entity A stays fixed. For each scenario, the AABB check subroutine computes whether |A.x - B.x| < 8 AND |A.y - B.y| < 8, storing 1 (collision) or 0 (no collision) in a result byte.

## Behavioral Contract

### Entity Positions

Entity A is fixed at (80, 80) for all scenarios.

- **Scenario 1** (frame 1): Entity B at (84, 83) — overlapping (dx=4, dy=3, both < 8). Result at $10 = 1.
- **Scenario 2** (frame 2): Entity B at (200, 200) — far apart (dx=120, dy=120). Result at $11 = 0.
- **Scenario 3** (frame 3): Entity B at (87, 80) — edge touching (dx=7, dy=0, both < 8). Result at $12 = 1.

### AABB Algorithm

Two 8x8 boxes overlap when: |A.x - B.x| < 8 AND |A.y - B.y| < 8.

On 6502, unsigned |A - B| < threshold is computed as:
1. Compute A - B. If carry clear (borrow), the result is negative, so compute B - A instead.
2. Compare result with threshold. If result < threshold, that axis overlaps.
3. Both axes must overlap for collision.

### RAM Layout (Zero Page)

- $10: scenario 1 result (expect 1)
- $11: scenario 2 result (expect 0)
- $12: scenario 3 result (expect 1)
- $13: frame_counter (NMI increment)

### Entity Storage

Entity A: zero page $20 (x), $21 (y)
Entity B: zero page $22 (x), $23 (y)

## Success Criteria

- $10 = 1 after scenario 1 (overlapping entities)
- $11 = 0 after scenario 2 (far apart entities)
- $12 = 1 after scenario 3 (edge touching entities)
- All tests pass with `prove -v t/`

## Out of Scope

- Entity movement or velocity
- More than 2 entities
- Non-square bounding boxes
- Collision response (bounce, destroy, etc.)
- OAM or sprite display
