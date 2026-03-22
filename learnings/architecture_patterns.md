# Game Architecture Patterns

**Source**: Validated through toys 15-17 (state machine, entities, collision)

Practical patterns for structuring NES game logic, entity management, and collision detection.

---

## State Machine (toy15)

### Pattern: ZP Byte + CMP/BEQ Dispatch

Single zero-page byte tracks current state. NMI handler reads controller, detects new presses, then dispatches to state-specific logic via CMP/BEQ chains.

**Validated**: 3 states (menu/gameplay/paused), Start button transitions, 5/5 tests.

**Key details**:
- State byte at $10, frame counter at $11
- Button edge detection: `EOR prev; AND current` → newly pressed only (3 instructions)
- Controller read: strobe $4016, LSR/ROL loop for 8 buttons
- For 3-8 states: direct CMP/BEQ is simpler than a jump table
- For 8+ states: consider indirect jump table via indexed addressing

**ZP layout** (5 bytes for controller + state):
- $10: game_state
- $11: frame_counter
- $12: buttons (A=80, B=40, Sel=20, Start=10, U=08, D=04, L=02, R=01)
- $13: buttons_prev
- $14: buttons_new

---

## Entity System (toy16)

### Pattern: Array-of-Structs at $0300

Fixed-size entity records in regular RAM, synced to shadow OAM ($0200) each NMI frame.

**Validated**: 4 entities with independent positions, 38/38 tests.

**Entity record** (8 bytes, power-of-2 stride):
- +0: x_pos, +1: y_pos, +2: tile, +3: attr
- +4: type, +5: state, +6: pad, +7: pad

**Indexing**: entity_index * 8 = 3x ASL for table offset.

**OAM sync**: NMI loops through entities, copies to shadow OAM with field reorder (entity: x,y,tile,attr → OAM: y,tile,attr,x), then triggers DMA via $4014.

**Memory allocation**:
- Entity table: $0300+ (regular RAM, not zero page)
- Shadow OAM: $0200-$02FF (standard convention)
- Zero page: only entity_count ($10) and frame_counter ($11)

**Scaling**: 4 entities = 32 bytes, 8 = 64, 16 = 128. NES has 64 hardware sprites max but only 8 per scanline.

---

## Collision Detection (toy17)

### Pattern: AABB via Unsigned Subtraction

Check overlap on both X and Y axes using 6502 unsigned arithmetic.

**Validated**: 3 scenarios (overlap, miss, edge touch), 4/4 tests.

**Algorithm** (~20 instructions):
1. SEC; SBC to compute A.x - B.x
2. Check carry: if clear (borrow), result is negative → negate via EOR #$FF; ADC #1
3. CMP #BOX_SIZE: if less, X axis overlaps
4. Repeat for Y axis
5. Both axes must overlap for collision

**Key insight**: Carry flag after SBC tells you which value was larger — no signed math needed.

**BOX_SIZE = 8**: matches standard NES 8x8 sprite size. Use different values for larger sprites (8x16 mode = BOX_SIZE 16 on Y axis).

**Performance**: ~20 instructions per pair check. For N entities, worst case is N*(N-1)/2 pairs. With 8 entities = 28 checks ≈ 560 instructions — easily fits in a frame.

---

## Key Takeaways

1. **ZP is precious** — use for counters, flags, button state. Bulk data (entities, OAM) goes in regular RAM.
2. **Power-of-2 strides** simplify 6502 indexing (ASL for *2, *4, *8). Worth the padding bytes.
3. **NMI-driven main loop** is the standard NES pattern: frame counter + controller + state + entity update + OAM sync.
4. **Edge detection for buttons** is essential — without it, a held button fires every frame.
5. **AABB is sufficient** for most NES games. Pixel-perfect collision is expensive and rarely needed.

---

## Attribution

Patterns validated through practical implementation in toys 15-17. See individual toy LEARNINGS.md files for detailed findings.
