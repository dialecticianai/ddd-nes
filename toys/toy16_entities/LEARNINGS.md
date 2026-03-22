# LEARNINGS — Entities

## Learning Goals

Validate an array-of-structs entity system on the NES: fixed-size entity records in RAM, synchronized to shadow OAM each frame via NMI. Proves we can manage 4-8 game objects with independent positions and copy them to hardware sprites.

### Cross-References

- `learnings/.ddd/5_open_questions.md` — Q4.2 (entity system), Q6.4 (zero page allocation)

### Questions to Answer

- **Q4.2**: What entity storage pattern works on 6502? Array-of-structs with fixed stride, or parallel arrays?
- **Q6.4**: Which entity variables belong in zero page vs regular RAM?

### Decisions to Make

- Entity record size (bytes per entity)
- Entity table base address
- How many entities to support initially
- Zero page usage for entity loop temporaries vs entity data itself

## Findings

(To be filled after implementation)

## Patterns for Production

(To be filled after implementation)
