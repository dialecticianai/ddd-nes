# LEARNINGS — MMC1 Bank Switching

## Learning Goals

Validate MMC1 serial write protocol and bank switching in jsnes.

### Cross-References

- `learnings/mappers.md` — MMC1 specs, serial protocol, interrupt safety
- `learnings/.ddd/5_open_questions.md` — Q5.6, Q7.1

## Findings

**Duration**: ~15 min | **Status**: Complete | **Result**: 4/4 tests passing

### Q1: jsnes MMC1 serial protocol

**Answer**: Yes — jsnes correctly emulates the 5-write serial shift register. The sequence `STA $E000; LSR A; STA $E000; ...` (5 times) correctly switches PRG banks. All 3 switchable banks verified.

### Q2: Mapper reset

**Answer**: `LDA #$80; STA $8000` (bit 7 set) resets the shift register. Used at power-on before control register configuration. Works in jsnes.

### Q3: UNROM-style quick setup

**Answer**: Writing $0E to control register ($8000-$9FFF) via serial protocol correctly configures fixed $C000 + switchable $8000 + CHR-RAM mode. This is the simplest MMC1 configuration and matches UNROM behavior.

### Q4: nes.cfg for MMC1

**Answer**: Identical to UNROM nes.cfg — only the iNES header changes. Same multi-bank MEMORY regions, same segment layout. The mapper hardware is transparent to the linker.

iNES header difference: `.byte $10, $00` (mapper 1) vs UNROM's `.byte $20, $08` (mapper 2 + NES 2.0).

### Note: Reset stubs

We did NOT implement the per-bank reset stub pattern from the wiki (placing vectors at the end of every bank for power-on safety). jsnes appears to initialize MMC1 in fixed-$C000 mode. For real hardware, the stubs would be needed on some MMC1 revisions. This could be a future enhancement if hardware testing reveals issues.

## Patterns for Production

- **MMC1 serial write**: `STA reg; LSR A; STA reg; LSR A; STA reg; LSR A; STA reg; LSR A; STA reg; RTS`
- **Control register init**: Write $0E to $8000 for UNROM-style (fixed $C000, CHR-RAM, vertical mirror)
- **PRG bank switch**: Serial write to $E000
- **Mapper reset**: Write $80 to $8000 (any address with bit 7 set)
- **NMI safety**: Reset mapper + restore bank at end of NMI handler
- **nes.cfg**: Identical to UNROM — only iNES header mapper number changes
