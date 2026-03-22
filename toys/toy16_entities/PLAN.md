# PLAN — Entities

## Overview

**Goal**: Validate array-of-structs entity storage and entity-to-OAM synchronization.

**Scope**: Single ROM, 4 entities, NMI-driven OAM sync, no movement or input.

**Methodology**: TDD with Phase 1 tools (assert_ram for entity table, assert_sprite for OAM verification).

---

## Steps

### Step 1: Build Entity ROM

**Goal**: Implement entity table at $0300 and NMI handler that syncs entities to shadow OAM.

Scaffold with new-rom.pl. Add a ZEROPAGE segment to nes.cfg for entity loop temporaries. The reset handler initializes 4 entities at hardcoded positions in the entity table ($0300-$031F, 8 bytes per entity). Each record stores x, y, tile, attr, type, state, and two padding bytes.

The NMI handler loops over all entities using X as the entity index and a stride of 8. For each entity, it reads x/y/tile/attr from the entity table and writes them to the corresponding OAM shadow slot at $0200 in the OAM byte order (Y, tile, attr, X). After the loop, it writes $02 to $4014 to trigger OAM DMA.

Zero page usage is minimal: entity_count at $10, frame_counter at $11, and a temp pointer at $12-$13 if needed for indirect addressing (though direct indexed addressing with X should suffice for 4 entities).

**Success Criteria**: make builds the ROM, entity data is at $0300+, OAM mirrors entity positions after first NMI.

---

### Step 2: Automated Tests

**Goal**: Verify entity storage and OAM sync via assert_ram and assert_sprite.

Write tests in t/01-entities.t. Use at_frame 4 (enough NMIs to sync). Verify all 4 entity records at $0300-$031F have correct x/y/tile/attr/type values via assert_ram. Verify OAM sprites 0-3 have matching positions via assert_sprite (y, tile, attr, x parameters).

**Success Criteria**: prove -v t/ passes all tests.

---

### Step 3: Finalize

Update LEARNINGS.md with findings about entity storage patterns and zero page allocation. Write README.md. Update toys/STATUS.md.

---

## Risks

1. **OAM byte order**: OAM stores (Y, tile, attr, X) not (X, Y, tile, attr). The entity table uses a game-friendly order; the NMI copy must reorder fields. Getting this wrong means assert_sprite will fail on all position checks.

2. **Entity stride arithmetic**: 8-byte stride means multiplying entity index by 8 (three ASL shifts). Off-by-one in stride calculation would corrupt all entity reads past the first.

## Dependencies

- NES/Test.pm: assert_ram, assert_sprite, at_frame (all exist)
- toy1_sprite_dma findings: OAM DMA pattern ($4014 = $02)
