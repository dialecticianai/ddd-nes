# LEARNINGS — Entities

## Learning Goals

Validate an array-of-structs entity system on the NES: fixed-size entity records in RAM, synchronized to shadow OAM each frame via NMI. Proves we can manage 4-8 game objects with independent positions and copy them to hardware sprites.

### Cross-References

- `learnings/.ddd/5_open_questions.md` — Q4.2 (entity system), Q6.4 (zero page allocation)

### Questions to Answer

- **Q4.2**: What entity storage pattern works on 6502? Array-of-structs with fixed stride, or parallel arrays?
- **Q6.4**: Which entity variables belong in zero page vs regular RAM?

## Findings

**Duration**: ~20 min | **Status**: Complete | **Result**: 38/38 tests passing

### Q4.2: Entity storage pattern

**Answer**: Array-of-structs with 8-byte stride (power of 2) at $0300. Each entity record: x, y, tile, attr, type, state, pad, pad. Indexed via X register with stride multiplication (3x ASL for *8).

Why 8 bytes: power-of-2 makes index math trivial. The 2 padding bytes are wasted but the simplicity is worth it. For 4 entities = 32 bytes. Even 16 entities = 128 bytes — fits easily in RAM.

Entity → OAM sync in NMI: loop through entities, copy x/y/tile/attr to shadow OAM ($0200) with field reordering (OAM order is Y, tile, attr, X — different from entity order).

### Q6.4: Zero page allocation

**Answer**: Only loop counters and metadata in zero page ($10: entity_count, $11: frame_counter). Entity data itself stays in regular RAM ($0300+) — it's accessed via indexed addressing which works the same speed for zero page and regular RAM. Zero page is too precious (256 bytes) to waste on entity tables.

## Patterns for Production

- **8-byte entity records** at $0300+ — power-of-2 stride for easy indexing
- **Entity fields**: x, y, tile, attr, type, state + 2 padding bytes
- **OAM sync**: NMI loop copies entity → shadow OAM with field reorder, then DMA ($4014)
- **Zero page**: counters/metadata only, entity data in regular RAM
- **Entity count**: track in ZP for fast loop termination
