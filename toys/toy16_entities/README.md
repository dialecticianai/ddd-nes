# Entities (toy16)

Entity/sprite management system with array-of-structs storage and OAM synchronization.

## Purpose

Validates storing game entities as fixed-size records in RAM and copying their positions to shadow OAM each frame. 4 entities at $0300 (8 bytes each: x, y, tile, attr, type, state, pad, pad) are synced to OAM sprites at $0200 by the NMI handler, which reorders fields to match OAM format (Y, tile, attr, X) and triggers DMA.

## Key APIs

```
Entity table: $0300-$031F (4 entities, 8-byte stride)
OAM shadow:   $0200-$020F (4 sprites, 4-byte stride)
Zero page:    $10 = entity_count, $11 = frame_counter

NMI: entity loop (read $0300+X) → write $0200+Y → OAM DMA ($4014=$02)
```

## Gotchas

- Entity record order (x, y, tile, attr) differs from OAM order (Y, tile, attr, X) -- NMI copy must reorder
- 8-byte entity stride chosen as power-of-2 for easy index math (3x ASL)
- Entity table at $0300 avoids conflict with OAM shadow at $0200

## Quick Test

```bash
cd toys/toy16_entities && make && prove -v t/
```
