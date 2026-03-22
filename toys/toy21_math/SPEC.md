# SPEC — Math Routines

## Purpose

Validate 6502 math routines (8x8 multiply, 8-bit divide) with correctness verification. The 6502 has no hardware multiply or divide — these must be implemented in software. This toy proves the standard routines work and stores results for test verification.

**Axis of complexity**: Shift-and-add multiply + repeated subtraction divide.

## Overview

The ROM implements a general 8x8 multiply (A * Y → 16-bit result) and an 8-bit divide (A / Y → quotient + remainder). Multiple test cases are computed during init and results stored in RAM for verification.

## Behavioral Contract

### Multiply (A * Y → result_lo, result_hi)
- 7 * 6 = 42 (result_lo = 42, result_hi = 0)
- 13 * 20 = 260 (result_lo = 4, result_hi = 1)
- 255 * 255 = 65025 (result_lo = 1, result_hi = 254)
- 0 * 99 = 0

### Divide (A / Y → quotient, remainder)
- 42 / 7 = 6 remainder 0
- 100 / 3 = 33 remainder 1
- 255 / 1 = 255 remainder 0
- 5 / 10 = 0 remainder 5

### RAM Layout
- $0300-$030F: multiply results (4 tests x 2 bytes: lo, hi)
- $0310-$031F: divide results (4 tests x 2 bytes: quotient, remainder)

## Success Criteria

- All 4 multiply results correct (8 bytes verified)
- All 4 divide results correct (8 bytes verified)
- Frame cycles in NTSC range
- All tests pass with `prove -v t/`

## Out of Scope

- 16-bit multiply/divide
- Fixed-point math
- Lookup table comparison (document in LEARNINGS only)
- Trigonometric functions
