# SPEC — RLE Compression

## Purpose

Validate RLE decompression on 6502: decompress run-length encoded data from ROM to RAM, verify output byte-by-byte. Measures decompression with Phase 2 cycle counting. RLE is the simplest practical compression for NES level/tile data.

**Axis of complexity**: RLE decode loop + output verification.

## Overview

The ROM contains RLE-compressed data in RODATA and a decompression routine that expands it to a RAM buffer ($0300+). The RLE format uses a simple byte-pair scheme: if a byte has bit 7 set, it's a run (length in bits 0-6, followed by the value to repeat); otherwise it's a literal byte. A terminator byte ($00 with bit 7 clear after a run) marks end of stream.

Tests verify the decompressed output matches expected data and frame cycles are in range.

## Data Format

RLE stream: sequence of commands, terminated by $80 (run of length 0).
- **Run**: byte with bit 7 set = run. Length = byte AND $7F. Next byte = value to repeat.
- **Literal**: byte with bit 7 clear = literal value, output directly.
- **End marker**: $80 (run of length 0) = stop.

Example: `$85, $FF, $03, $42, $83, $AA, $80` decodes to: `FF FF FF FF FF 03 42 AA AA AA`

## Success Criteria

- Decompressed data in RAM matches expected byte sequence
- At least 10 bytes of output verified
- Multiple runs and literals in the test data
- Frame cycles in NTSC range
- All tests pass with `prove -v t/`

## Out of Scope

- LZ compression (more complex, deferred)
- Streaming decompression during scrolling
- Compressing data at build time (test data is hand-crafted)
