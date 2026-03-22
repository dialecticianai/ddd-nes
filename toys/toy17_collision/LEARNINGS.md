# LEARNINGS — Collision

## Learning Goals

Validate AABB (axis-aligned bounding box) collision detection between two entities on the NES. Proves that unsigned subtraction and comparison can determine overlap for 8x8 bounding boxes using only 6502 arithmetic.

### Cross-References

- `learnings/.ddd/5_open_questions.md` — Q4.3 (bounding box collision), Q4.4 (pixel-perfect vs AABB)

### Questions to Answer

- **Q4.3**: How to implement AABB collision on 6502 with unsigned math?
- **Q4.4**: Is AABB sufficient for NES games, or do we need pixel-perfect?

### Decisions to Make

- How to handle the unsigned subtraction for |A.x - B.x| (no signed abs on 6502)
- Whether to use a shared collision subroutine or inline the check
- Where to store collision results (zero page for speed vs RAM for capacity)

## Findings

(To be filled after implementation)

## Patterns for Production

(To be filled after implementation)
