# RLE Compression (toy20)

Run-length encoding decompression on 6502.

## Purpose

Validates RLE decompression from ROM to RAM. Bit-7 flag format: runs (length + value) vs literals. Proves compressed level data can be expanded at init time with trivial cycle cost.

## Key API

```
RLE format: bit 7 set = run (len in 0-6, next byte = value)
            bit 7 clear = literal byte
            $80 = end marker
Decompressor: ~40 instructions, 16-bit ZP pointers for src/dst
```

## Core Concepts

- `LDA (ptr), Y` with Y=0 for 16-bit indirect addressing
- Manual pointer increment: `INC ptr; BNE :+; INC ptr+1`
- Run count stored in ZP temp (run_count) to free A/X for data operations
- Init-time decompression — no vblank constraint

## Gotchas

- Literal bytes $80-$FF can't be used in this format (bit 7 collision) — production needs escape-byte variant
- NES RAM not zero-initialized — don't assume unwritten memory is $00
- Test data is hand-crafted; a build-time compressor tool would be needed for production

## Quick Test

```bash
cd toys/toy20_compression && make && prove -v t/
```
