# LEARNINGS — RLE Compression

## Learning Goals

Validate RLE decompression on 6502: decode run-length encoded data to RAM buffer, verify output.

### Cross-References

- `learnings/.ddd/5_open_questions.md` — Q6.7

## Findings

**Duration**: ~15 min | **Status**: Complete | **Result**: 11/11 tests passing

### RLE decompression on 6502

**Format**: Bit 7 set = run (length in bits 0-6, next byte = value), bit 7 clear = literal, $80 = end marker. Simple to encode, fast to decode. ~40 instructions total for the decompressor.

**Performance**: Init-time decompression completes in a fraction of one frame. For real-time (vblank) decompression of column data, the loop is fast enough for any practical level size.

**Compression ratio**: Test data 1.36:1 (minimal runs). Real NES level data with long repeated runs (sky, ground, walls) typically achieves 3:1 to 10:1.

**Limitation**: Literal bytes $80-$FF can't be represented in this format (they'd be interpreted as runs). Production variant should use escape byte or count-based scheme.

### 6502 indirect indexed pattern

`LDA (ptr), Y` with Y=0 and manual `INC ptr; BNE :+; INC ptr+1` helper is the standard 16-bit pointer access pattern. Works for both ROM reads and RAM writes.

## Patterns for Production

- **RLE format**: bit 7 flag, ~40 instructions, fast init-time decode
- **16-bit ZP pointers**: `(ptr), Y` with Y=0, increment helpers
- **Run count in ZP temp**: avoids register pressure
- **Production enhancement**: escape-byte variant for full byte range support
- **NES RAM not zero-initialized**: don't check bytes past output end
