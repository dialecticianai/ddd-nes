# SPEC — UNROM Bank Switching

## Purpose

Validate UNROM (mapper 2) bank switching with ca65/ld65: switching the 16KB bank at $8000-$BFFF, reading data from multiple banks, and using the bus conflict lookup table pattern. Proves we can build multi-bank ROMs and verify correct bank mapping via the test harness.

**Axis of complexity**: Mapper register writes + multi-bank linker configuration.

## Overview

The ROM has 4 x 16KB PRG banks (64KB total). Banks 0-2 are switchable ($8000-$BFFF), bank 3 is fixed ($C000-$FFFF). Each switchable bank contains a unique marker byte at a known offset. The fixed bank contains the reset code, bankswitch routine (with bus conflict table), and NMI handler. After init, the ROM switches to each bank in sequence and copies the marker to a RAM location. Tests verify the correct marker appears for each bank.

## Behavioral Contract

### ROM Structure
- iNES header declares mapper 2, 4 x 16KB PRG-ROM banks, CHR-RAM
- Bank 3 (fixed at $C000-$FFFF): reset, NMI, bankswitch routine, bus conflict table
- Banks 0-2 (switchable at $8000-$BFFF): each contains a unique marker byte at the same offset

### Bank Switching
- Bankswitch routine uses the standard `sta banktable, y` bus conflict pattern
- After switching to bank N, reading the marker address at $8000+offset returns bank N's unique value
- Marker values stored to RAM for test harness verification

### Test Markers
- Bank 0 marker: $AA at $8000
- Bank 1 marker: $BB at $8000
- Bank 2 marker: $CC at $8000
- After switching to each bank, the marker is copied to a RAM address ($10, $11, $12)

## Success Criteria

- `make` builds a 64KB UNROM ROM (mapper 2)
- ROM boots and switches through banks 0, 1, 2 successfully
- RAM $10 = $AA (bank 0 marker verified)
- RAM $11 = $BB (bank 1 marker verified)
- RAM $12 = $CC (bank 2 marker verified)
- All tests pass with `prove -v t/`

## Out of Scope

- CHR-RAM tile loading (this toy uses no graphics)
- NMI-during-bankswitch safety (that's toy14_mmc1 territory)
- UOROM (256KB) variant
- Actual game logic across banks
