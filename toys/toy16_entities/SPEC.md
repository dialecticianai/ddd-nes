# SPEC — Entities

## Purpose

Validate an entity/sprite management system: store 4 entities as fixed-size records in RAM, then synchronize their positions to shadow OAM ($0200) each NMI. Proves array-of-structs entity storage and entity-to-OAM copy work for game object management.

**Axis of complexity**: Entity storage + OAM synchronization.

## Overview

The ROM initializes 4 entities at known positions in an entity table at $0300. Each entity is an 8-byte record: X, Y, tile, attributes, type, state, and 2 padding bytes. The NMI handler copies each entity's X/Y/tile/attr to the corresponding shadow OAM slot at $0200, then triggers OAM DMA. No movement or game logic — pure storage and sync test.

## Behavioral Contract

### Entity Table ($0300-$031F)

4 entities, 8 bytes each:

| Offset | Field | Description |
|--------|-------|-------------|
| +0 | x_pos | X position (0-255) |
| +1 | y_pos | Y position (0-239) |
| +2 | tile | CHR tile index |
| +3 | attr | Sprite attributes (palette, flip) |
| +4 | type | Entity type (0=inactive, 1+=active types) |
| +5 | state | Entity state (type-specific) |
| +6 | pad0 | Reserved |
| +7 | pad1 | Reserved |

### Entity Positions (Initial)

- Entity 0: (32, 40), tile $01, attr $00, type 1
- Entity 1: (80, 60), tile $02, attr $00, type 1
- Entity 2: (128, 100), tile $03, attr $01, type 1
- Entity 3: (200, 150), tile $04, attr $02, type 1

### OAM Layout ($0200-$020F)

Each entity maps to one OAM sprite (4 bytes: Y, tile, attr, X):

- Sprite 0 ($0200): Y=40, tile=$01, attr=$00, X=32
- Sprite 1 ($0204): Y=60, tile=$02, attr=$00, X=80
- Sprite 2 ($0208): Y=100, tile=$03, attr=$01, X=128
- Sprite 3 ($020C): Y=150, tile=$04, attr=$02, X=200

### NMI Behavior

1. Loop over 4 entities, copy X/Y/tile/attr to shadow OAM
2. Trigger OAM DMA ($4014 = $02)

### RAM Layout (Zero Page)

- $10: entity_count (number of active entities, currently 4)
- $11: frame_counter (increments each NMI)
- $12-$13: temp pointer (for entity table indexing)

## Success Criteria

- Entity data present at $0300-$031F with correct values
- OAM sprites at $0200+ mirror entity positions after NMI
- 4 entities with distinct X/Y positions
- All tests pass with `prove -v t/`

## Out of Scope

- Entity movement or velocity
- Entity spawning/despawning
- Collision detection
- More than 4 entities (validated pattern, not stress test)
- Controller input
