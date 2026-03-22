# Collision (toy17)

AABB collision detection between two entities using 6502 unsigned arithmetic.

## What This Toy Does

Tests axis-aligned bounding box overlap for 8x8 sprites. Entity A is fixed at (80, 80); the NMI handler sequences entity B through 3 positions across 3 frames: overlapping (84, 83), far apart (200, 200), and edge-touching (87, 80). Each scenario stores a collision flag (1 or 0) in zero page.

## Key APIs

```
Entity positions: $20-$23 (A.x, A.y, B.x, B.y in zero page)
Collision results: $10 = scenario 1, $11 = scenario 2, $12 = scenario 3
Frame counter: $13

check_aabb: Returns A=1 (collision) or A=0 (no collision)
Algorithm: |A.x - B.x| < 8 AND |A.y - B.y| < 8
```

## Gotchas

- 6502 has no signed absolute value. Use SEC/SBC, check carry to detect negative, then negate with EOR #$FF / ADC #1.
- Edge case: dx=7 counts as collision (< 8), dx=8 does not. This matches 8-pixel-wide sprites where pixel 0-7 overlap at distance 7 but not at distance 8.
- AABB is sufficient for most NES games; pixel-perfect collision is rarely worth the cost.

## Quick Test

```bash
cd toys/toy17_collision && make && prove -v t/
```
