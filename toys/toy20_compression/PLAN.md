# PLAN — RLE Compression

## Overview

**Goal**: Validate RLE decompression on 6502 with cycle measurement

**Scope**: Single ROM, decompress RLE data to RAM buffer, verify output

**Methodology**: TDD with Phase 2 tools (assert_ram for output, assert_frame_cycles)

---

## Steps

### Step 1: Build RLE Decompression ROM

**Goal**: Implement RLE decoder and decompress test data to RAM.

Create a simple RLE format (bit 7 flag for runs vs literals). Store compressed test data in RODATA with known expected output. The decompression routine reads from a source pointer (RODATA address), writes to a destination pointer ($0300+), and handles both runs and literals. Run during init (before rendering) so there's no vblank constraint on this first test.

Store the output byte count in a ZP variable for test verification.

**Success Criteria**:
- `make` builds the ROM
- Decompressed data appears in RAM at $0300+

**Commit**: `feat(compression): Step 1 — RLE decompression ROM`

---

### Step 2: Automated Tests

**Goal**: Verify decompressed bytes match expected output.

Check multiple RAM positions in the output buffer against known expected values. Verify both run-expanded bytes and literal bytes. Check the output length counter. Verify frame cycles in normal range.

**Success Criteria**:
- `prove -v t/` passes all tests
- At least 10 output bytes verified
- Both runs and literals verified
- Output length correct
- Frame cycles in range

**Commit**: `feat(compression): Step 2 — automated RLE decompression tests`

---

### Step 3: Finalize

**Commit**: `docs(compression): complete toy20 with findings`

---

## Risks

1. **Pointer arithmetic on 6502**: Need indirect indexed addressing for source/dest pointers. Requires 16-bit pointers in zero page.
2. **RLE format edge cases**: Ensure the end marker ($80) is handled correctly and doesn't corrupt output.

## Dependencies

- `lib/NES/Test.pm` — assert_ram, assert_frame_cycles
