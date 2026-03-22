# MMC1 Bank Switching (toy14)

MMC1 (mapper 1) serial write protocol and bank switching.

## Purpose

Validates MMC1's 5-write serial shift register for configuring the control register and switching PRG banks. Uses UNROM-style mode (fixed $C000, switchable $8000, CHR-RAM). Proves jsnes correctly emulates the serial protocol.

## Key API

```
mmc1_write_control:     ; A = 5-bit value, writes to $8000 serially
mmc1_load_prg_bank:     ; A = bank number, writes to $E000 serially
  STA reg; LSR A; STA reg; (x5 total); RTS

Mapper reset: LDA #$80; STA $8000
Control init: LDA #$0E; JSR mmc1_write_control
```

## Core Concepts

- 5-write serial protocol: write bit 0 of value 5 times, LSR between each
- Control register ($8000): mode, mirroring, CHR size
- PRG bank register ($E000): selects switchable bank at $8000-$BFFF
- nes.cfg identical to UNROM — only iNES header mapper number differs

## Gotchas

- NMI can corrupt shift register mid-write — reset mapper ($80→$8000) + restore bank in NMI handler
- Some MMC1 revisions don't guarantee fixed-$C000 at power-on (need reset stubs in all banks for real hardware — not tested here)
- Serial write takes ~30 cycles (5 writes + LSR) vs UNROM's single-write bankswitch

## Quick Test

```bash
cd toys/toy14_mmc1 && make && prove -v t/
```
