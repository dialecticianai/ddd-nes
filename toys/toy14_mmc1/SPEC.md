# SPEC — MMC1 Bank Switching

## Purpose

Validate MMC1 (mapper 1) serial write protocol, mapper reset, and bank switching. MMC1 is Nintendo's first ASIC mapper, requiring a 5-write serial sequence to change registers. This toy proves the protocol works in jsnes and establishes the ca65/ld65 linker pattern for MMC1 ROMs.

**Axis of complexity**: Serial write protocol + mapper initialization + bank switching.

## Overview

The ROM uses MMC1 in "UNROM-style" mode (fixed $C000, switchable $8000, CHR-RAM). After power-on, it resets the mapper, configures the control register via the 5-write protocol, then switches through PRG banks and reads marker bytes — the same verification pattern as toy13_unrom, but using MMC1's serial interface.

## Behavioral Contract

### ROM Structure
- iNES header declares mapper 1, 4 x 16KB PRG banks, CHR-RAM
- Bank 3 (fixed at $C000-$FFFF): reset, NMI, mapper routines
- Banks 0-2 (switchable at $8000-$BFFF): unique marker byte at $8000 each
- Reset stub in all banks (per wiki recommendation for MMC1 power-on quirk)

### Mapper Initialization
- Reset mapper by writing $80 to $8000 (bit 7 high clears shift register)
- Configure control register: write $0E serially to $8000 (fixed $C000, CHR-RAM, vertical mirroring)

### Bank Switching
- Switch via 5-write serial sequence to $E000 (PRG bank register)
- After switching to bank N, marker at $8000 returns bank N's unique value
- Markers stored to RAM for test harness verification

### Test Markers
- Bank 0: $AA at $8000, Bank 1: $BB at $8000, Bank 2: $CC at $8000
- After switching: RAM $11 = $AA, $12 = $BB, $13 = $CC

## Success Criteria

- `make` builds a 64KB MMC1 ROM (mapper 1)
- RAM $11 = $AA (bank 0), $12 = $BB (bank 1), $13 = $CC (bank 2)
- All tests pass with `prove -v t/`

## Out of Scope

- CHR-ROM bank switching (this uses CHR-RAM)
- PRG-RAM / save game support
- NMI-during-serial-write interrupt testing (would need cycle-precise NMI timing)
- Multiple MMC1 modes (only test fixed-$C000 mode)
