# df-nes — 2D Daggerfall on NES

**A top-down 2D adaptation of The Elder Scrolls II: Daggerfall for the NES, split across multiple ROM cartridges with transferable save files.**

---

## Problem Statement

Daggerfall (1996) is one of the most ambitious RPGs ever made — a procedurally generated world the size of Great Britain with hundreds of towns, thousands of dungeons, and deep character progression. But its first-person 3D engine and Windows-only platform make it inaccessible on retro hardware.

NES RPGs like Dragon Quest, Final Fantasy, and Ultima proved that vast worlds and deep systems can thrive within extreme constraints. The question: can Daggerfall's procedural world generation, guild systems, and open-ended gameplay translate to 8-bit hardware?

## Target Users

**Primary**: NES homebrew enthusiasts, retro gaming community, Daggerfall fans curious about demakes

**Secondary**: LLM-assisted game development researchers (this project demonstrates DDD methodology at scale)

## Solution Approach

### Core Insight

Daggerfall's world is **procedurally generated from seeds and lookup tables** — exactly the kind of computation a 6502 can do. We don't need to store a massive world map. We need the *algorithm* and the *data tables*.

### Multi-ROM Architecture

One ROM per region of Tamriel. Each ROM is a self-contained game with:
- The region's overworld (procedural terrain, towns, dungeons)
- Shared game engine (RPG systems, renderer, audio)
- SRAM save slot with portable character data

**Save transfer**: Player saves character to battery-backed SRAM ($6000-$7FFF, 8KB). Swap to a different region's ROM. Character loads from SRAM — stats, inventory, level, quest flags all preserved.

### Data Source

- **Daggerfall is free**: Official free download from Bethesda
- **Daggerfall Unity**: Open-source reimplementation with fully documented data formats
- **No reverse engineering**: Extract world data, monster stats, item tables, quest templates from documented sources
- **2D adaptation**: Transform first-person 3D into top-down 2D (Ultima/Zelda style)

## Starting Scope (v0.1 — "Morrowind Region")

One ROM, one region, core RPG loop:

1. **Overworld**: Procedural terrain for Morrowind region, ~5 visitable towns
2. **Towns**: Enter/exit, shops (buy/sell), guild hall (accept quests), inn (save)
3. **Dungeons**: One procedural dungeon type (prefab rooms connected by layout algorithm)
4. **Combat**: Top-down real-time (Zelda-style), warrior class only
5. **Character**: Stats (STR/DEX/END/etc.), level progression, inventory (weapons/armor/potions)
6. **Quests**: 3-5 template quests (kill monster, retrieve item, deliver message)
7. **Save**: SRAM with character data structured for cross-ROM portability

### What v0.1 Defers

- Magic system, stealth system (future ROMs/updates)
- Multiple character classes
- Horse/fast travel beyond town-to-town
- Reputation/political systems
- Additional regions (that's what the multi-ROM architecture is for)
- Music (SFX only initially)

## Technical Foundation

All core subsystems validated through 22 toy ROMs (316 tests passing):

| Subsystem | Toy | Pattern |
|-----------|-----|---------|
| Graphics pipeline | toy10 | PNG → CHR-ROM |
| Tile rendering | toy11 | Attribute table palettes |
| Level data | toy12 | Metatile compression (4:1) |
| Bank switching | toy13-14 | UNROM + MMC1 |
| Game flow | toy15 | State machine + controller |
| Entities | toy16 | Array-of-structs + OAM sync |
| Collision | toy17 | AABB detection |
| Scrolling | toy18 | Column streaming in vblank |
| Dynamic tiles | toy19 | CHR-RAM loading |
| Compression | toy20 | RLE decompression |
| Math | toy21 | 8x8 multiply + divide |
| Audio | toy22 | Multi-channel + SFX priority |

## Guiding Principles

1. **Procedural over static**: Generate the world at runtime, don't store it. This is how the original Daggerfall works and it's perfect for NES ROM constraints.

2. **Portable save, not portable code**: Each ROM is a complete game. Only the character data crosses ROM boundaries. Keep the save format simple and versioned.

3. **Authentic feel over faithful recreation**: We're not porting Daggerfall. We're making an NES RPG *inspired by* Daggerfall's world, systems, and procedural philosophy.

4. **One axis at a time**: Build the engine incrementally. Overworld first, then towns, then dungeons, then combat, then quests. Each is a DDD discovery/execution cycle.

5. **Data-driven design**: Extract tables from Daggerfall Unity, don't hand-author content. Monster stats, item properties, town names — all from the original data files.

---

## Success Criteria

**v0.1 Minimum Viable:**
- [ ] Player can walk around a procedural overworld
- [ ] Enter a town, buy a weapon, accept a quest
- [ ] Enter a dungeon, fight a monster, collect loot
- [ ] Level up, save game, load game
- [ ] ROM builds and runs on jsnes (automated tests)
- [ ] ROM runs on Mesen2 (manual visual validation)

**v0.2 Multi-ROM:**
- [ ] Second region ROM loads character from first ROM's SRAM
- [ ] Character stats, inventory, level all transfer correctly

---

*Built with Dialectic-Driven Development. Toys are reconnaissance — the game is construction.*
