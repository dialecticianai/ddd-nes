# UNROM Bank Switching (toy13)

UNROM (mapper 2) bank switching with multi-bank ca65/ld65 linker config.

## Purpose

Validates UNROM bank switching: 4 x 16KB PRG banks, write to $8000-$FFFF to switch the bank mapped at $8000-$BFFF, bus conflict lookup table pattern. Proves we can build multi-bank ROMs and verify correct bank mapping via jsnes.

## Key API

```
bankswitch_y:           ; Y = bank number (0-2)
  sty current_bank      ; save for NMI restore
  tya
  sta banktable, Y      ; bus conflict safe write
  rts
```

## Core Concepts

- 4 banks: 0-2 switchable ($8000-$BFFF), 3 fixed ($C000-$FFFF)
- nes.cfg: multiple MEMORY regions with same `start=$8000`, sequential `file=%O`
- Bus conflict table: `banktable[N] = N` in RODATA (fixed bank)
- NMI must restore bank at end: `ldy current_bank; tya; sta banktable, Y`

## Gotchas

- All vectors, reset, bankswitch routine, and bus conflict table MUST be in fixed bank
- jsnes doesn't emulate bus conflicts, but the table pattern works on both emulator and hardware
- iNES header byte 4 = number of 16KB PRG banks (not number of switchable banks)
- `inspect-rom.pl` only reads first 32KB, so it shows bank 0/1 data, not the fixed bank

## Quick Test

```bash
cd toys/toy13_unrom && make && prove -v t/
```
