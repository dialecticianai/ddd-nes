# LEARNINGS — UNROM Bank Switching

## Learning Goals

Validate UNROM (mapper 2) bank switching with ca65/ld65 multi-bank linker config.

### Cross-References

- `learnings/mappers.md` — UNROM specs, bus conflict table
- `learnings/.ddd/5_open_questions.md` — Q5.4, Q5.5

## Findings

**Duration**: ~20 min | **Status**: Complete | **Result**: 4/4 tests passing

### Q1: jsnes UNROM support

**Answer**: Yes — jsnes has `Mappers[2]` and correctly emulates bank switching. Write to $8000-$FFFF with the bank number and $8000-$BFFF immediately maps to the new bank. All 3 switchable banks (0, 1, 2) verified via unique marker bytes.

### Q2: Bus conflict table

**Answer**: The standard `sta banktable, Y` pattern works. jsnes likely doesn't emulate bus conflicts (most emulators don't), but the pattern is correct for real hardware and works in the emulator too. The table must be in the fixed bank ($C000-$FFFF).

### Q3: Multi-bank nes.cfg

**Answer**: The key insight is that multiple MEMORY regions with `file = %O` and the same `start` address are written sequentially to the output file. For 4-bank UNROM:

- `BANK0: start=$8000, size=$4000` (16KB)
- `BANK1: start=$8000, size=$4000`
- `BANK2: start=$8000, size=$4000`
- `BANK3: start=$C000, size=$3FFA` (fixed, minus vectors)
- `ROMV: start=$FFFA, size=$0006`

Each bank gets its own segment (`BANK0DAT`, `BANK1DAT`, etc.). The fixed bank gets `CODE` and `RODATA`. ld65 writes them in order: header → bank0 → bank1 → bank2 → bank3+vectors.

iNES header: `.byte $04` for PRG count (4 x 16KB), `.byte $00` for CHR (CHR-RAM), `.byte $20, $08` for mapper 2 + NES 2.0.

### Q4: Bank verification via test harness

**Answer**: Simple pattern — place unique marker byte at known address in each bank ($8000), switch bank, read marker, store to RAM. `assert_ram` verifies. Also track `current_bank` in ZP for NMI handler restore.

## Patterns for Production

- **nes.cfg multi-bank pattern**: Multiple MEMORY regions with same `start`, sequential `file=%O`
- **Bus conflict table**: `banktable[N] = N` in RODATA, fixed bank
- **Bankswitch routine**: `sty current_bank; tya; sta banktable, Y; rts` (fixed bank)
- **NMI bank restore**: `ldy current_bank; tya; sta banktable, Y` at end of NMI
- **64KB ROM = 4 banks** (banks 0-2 switchable, bank 3 fixed)
- **Vectors + reset + bankswitch** all in fixed bank ($C000-$FFFF)
