# LEARNINGS — Math Routines

## Learning Goals

Validate 6502 math routines: general 8x8 multiply and 8-bit divide.

### Cross-References

- `learnings/math_routines.md` — Reference implementations
- `learnings/.ddd/5_open_questions.md` — Q6.6

## Findings

**Duration**: ~20 min | **Status**: Complete | **Result**: 17/17 tests passing

### Multiply: correct, ~200 cycles

The standard shift-and-add 8x8 multiply works correctly for all test cases including edge cases (0*N, 255*255). Pre-shifts first multiplicand bit, then 8-iteration loop: BCC/ADC conditional add, ROR to shift result right. Returns 16-bit result in A (low) and X (high).

### Divide: correct after bug fix, ~200-250 cycles

Initial implementation had double-shift bug: `ASL dividend` + `ROL dividend` in same loop shifted twice per iteration. Fix: pre-shift first bit with `ASL` before loop, then only `ROL` inside loop for both shifting bits out and result bits in.

Key insight: `ROL` serves dual purpose — shifts next dividend bit out (into carry) AND shifts quotient bit in (from carry after compare/subtract).

### Bug found in learnings/math_routines.md

The divide routine in the learnings doc has the same ASL+ROL double-shift bug AND a result register swap error. Should be corrected.

### Q6.6: When to use math routines

- **Powers of 2**: Always use shifts — 2 cycles/shift
- **Known constants**: Shift+add decomposition — 10-30 cycles
- **Variable operands**: General routine — ~200 cycles multiply, ~250 divide
- **Frequent variable ops**: 256-byte lookup table — 4-5 cycles/lookup
- **Division in game loop**: Avoid. Multiply-by-inverse or restructure logic

## Patterns for Production

- **8x8 multiply**: Pre-shift + 8x BCC/ADC/ROR loop, result in A:X
- **8-bit divide**: Pre-shift + 8x ROL/CMP/SBC/ROL loop, quotient=A, remainder=Y
- **4 ZP bytes**: factor1, factor2, dividend, divisor
- **Never divide by zero**: infinite loop. Guard in caller
- **Prefer shifts**: structure data for power-of-2 sizes
