# Math Routines (toy21)

General 8x8 multiply and 8-bit divide for 6502.

## Purpose

Validates software math routines since the 6502 has no hardware multiply or divide. Tests both routines across multiple cases including edge cases (0, 255*255, divide with remainder). Discovered and fixed a bug in the learnings doc's divide implementation.

## Key API

```
multiply: A*Y → A(lo), X(hi)   ; ~200 cycles
divide:   A/X → A(quot), Y(rem) ; ~250 cycles
ZP temps: factor1, factor2, dividend, divisor (4 bytes)
```

## Core Concepts

- Multiply: shift-and-add (pre-shift + 8x BCC/ADC/ROR loop)
- Divide: restoring division (pre-shift ASL + 8x ROL/CMP/SBC/ROL loop)
- ROL dual purpose in divide: shifts dividend bits out AND quotient bits in
- For constants, shift+add decomposition is 10x faster

## Gotchas

- Divide by zero = infinite loop. Must guard in caller.
- `ASL` + `ROL` on same variable in a loop = double shift bug (shifts twice per iteration)
- The divide pre-shifts first bit with `ASL` BEFORE the loop, then uses only `ROL` inside
- learnings/math_routines.md has incorrect divide implementation (needs correction)

## Quick Test

```bash
cd toys/toy21_math && make && prove -v t/
```
