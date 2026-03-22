# LEARNINGS — Collision

## Learning Goals

Validate AABB (axis-aligned bounding box) collision detection between two entities on the NES. Proves that unsigned subtraction and comparison can determine overlap for 8x8 bounding boxes using only 6502 arithmetic.

### Cross-References

- `learnings/.ddd/5_open_questions.md` — Q4.3 (bounding box collision), Q4.4 (pixel-perfect vs AABB)

### Questions to Answer

- **Q4.3**: How to implement AABB collision on 6502 with unsigned math?
- **Q4.4**: Is AABB sufficient for NES games, or do we need pixel-perfect?

## Findings

**Duration**: ~15 min | **Status**: Complete | **Result**: 4/4 tests passing

### Q4.3: AABB on 6502

**Answer**: SEC/SBC to subtract positions, check carry to determine sign, negate via EOR #$FF / ADC #1 if needed (absolute value), then CMP against box size. Both X and Y axes must pass for collision. ~20 instructions total for a full 2-axis check.

Pattern: `|A.x - B.x| < width AND |A.y - B.y| < height`

The carry flag after SBC tells you which value was larger — no need for signed math. If carry is clear (borrow occurred), the result is negative and needs negation to get absolute value.

### Q4.4: AABB vs pixel-perfect

**Answer**: AABB is sufficient for most NES games. 8x8 bounding boxes match sprite size naturally. The ~20-instruction cost is negligible even for checking many entity pairs. Pixel-perfect collision would require reading CHR-ROM data and comparing pixel masks — vastly more expensive and unnecessary for action/platformer games.

Three scenarios validated:
1. Overlapping entities → collision detected (flag = 1)
2. Far apart entities → no collision (flag = 0)
3. Edge-touching entities → collision detected (flag = 1, by design — `<` not `<=` for box size comparison)

## Patterns for Production

- **AABB check subroutine**: SEC/SBC for difference, carry flag for sign, EOR/ADC for abs, CMP for threshold
- **8x8 box size**: matches standard NES sprite size, BOX_SIZE constant for configurability
- **Result in ZP flag**: cheap to branch on in game logic
- **NMI-sequenced scenarios**: use frame counter to test multiple positions across frames
