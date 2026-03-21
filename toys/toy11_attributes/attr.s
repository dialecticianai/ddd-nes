; attr.s — Attribute table test ROM
;
; Demonstrates attribute table encoding for multi-palette backgrounds.
; Fills a region with tiles, then writes attribute bytes to assign
; different palettes to different 16x16 pixel quadrants.
;
; Attribute byte layout (each covers 4x4 tiles = 32x32 pixels):
;   bits 1-0: top-left     2x2 tile quadrant (palette 0-3)
;   bits 3-2: top-right    2x2 tile quadrant (palette 0-3)
;   bits 5-4: bottom-left  2x2 tile quadrant (palette 0-3)
;   bits 7-6: bottom-right 2x2 tile quadrant (palette 0-3)
;
; --- Test layout ---
;
; Attribute byte $23C0 (col 0-3, row 0-3):
;   TL=0, TR=1, BL=2, BR=3 → %11_10_01_00 = $E4
;   This proves all 4 quadrant fields work independently.
;
; Attribute byte $23C1 (col 4-7, row 0-3):
;   All quadrants = palette 2 → %10_10_10_10 = $AA
;   This proves uniform palette assignment.
;
; Nametable: Fill rows 0-3, cols 0-7 with tile $01 (solid dark gray)
;   = 32 tiles covering both attribute byte regions

PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
PPUADDR   = $2006
PPUDATA   = $2007

.segment "HEADER"
    .byte "NES", $1A
    .byte $01              ; 1x 16KB PRG-ROM
    .byte $01              ; 1x 8KB CHR-ROM
    .byte $00              ; Mapper 0, horizontal mirroring
    .byte $00
    .res 8, $00

.segment "ZEROPAGE"
    temp: .res 1

.segment "CODE"

reset:
    SEI
    CLD
    LDX #$FF
    TXS

    INX                    ; X = 0
    STX PPUCTRL
    STX PPUMASK
    BIT PPUSTATUS

    ; Wait 2 vblanks for PPU warmup
vblankwait1:
    BIT PPUSTATUS
    BPL vblankwait1
vblankwait2:
    BIT PPUSTATUS
    BPL vblankwait2

    ; --- Load 4 background palettes ---
    BIT PPUSTATUS
    LDA #$3F
    STA PPUADDR
    LDA #$00
    STA PPUADDR            ; Address = $3F00

    ; Palette 0: black, red, dark red, white
    LDA #$0F               ; $3F00: black (shared BG color)
    STA PPUDATA
    LDA #$16               ; $3F01: red
    STA PPUDATA
    LDA #$06               ; $3F02: dark red
    STA PPUDATA
    LDA #$30               ; $3F03: white
    STA PPUDATA

    ; Palette 1: black, green, dark green, light green
    LDA #$0F               ; $3F04: black
    STA PPUDATA
    LDA #$1A               ; $3F05: green
    STA PPUDATA
    LDA #$0A               ; $3F06: dark green
    STA PPUDATA
    LDA #$2A               ; $3F07: light green
    STA PPUDATA

    ; Palette 2: black, blue, dark blue, light blue
    LDA #$0F               ; $3F08: black
    STA PPUDATA
    LDA #$12               ; $3F09: blue
    STA PPUDATA
    LDA #$02               ; $3F0A: dark blue
    STA PPUDATA
    LDA #$22               ; $3F0B: light blue
    STA PPUDATA

    ; Palette 3: black, purple, dark purple, light purple
    LDA #$0F               ; $3F0C: black
    STA PPUDATA
    LDA #$14               ; $3F0D: purple
    STA PPUDATA
    LDA #$04               ; $3F0E: dark purple
    STA PPUDATA
    LDA #$24               ; $3F0F: light purple
    STA PPUDATA

    ; --- Fill nametable: rows 0-3, cols 0-7 with tile $01 ---
    ; Row 0: $2000-$2007
    BIT PPUSTATUS
    LDA #$20
    STA PPUADDR
    LDA #$00
    STA PPUADDR
    LDX #0
fill_row0:
    LDA #$01
    STA PPUDATA
    INX
    CPX #8
    BNE fill_row0

    ; Row 1: $2020-$2027
    LDA #$20
    STA PPUADDR
    LDA #$20
    STA PPUADDR
    LDX #0
fill_row1:
    LDA #$01
    STA PPUDATA
    INX
    CPX #8
    BNE fill_row1

    ; Row 2: $2040-$2047
    LDA #$20
    STA PPUADDR
    LDA #$40
    STA PPUADDR
    LDX #0
fill_row2:
    LDA #$01
    STA PPUDATA
    INX
    CPX #8
    BNE fill_row2

    ; Row 3: $2060-$2067
    LDA #$20
    STA PPUADDR
    LDA #$60
    STA PPUADDR
    LDX #0
fill_row3:
    LDA #$01
    STA PPUDATA
    INX
    CPX #8
    BNE fill_row3

    ; --- Write attribute bytes ---
    ; Attribute byte 0 at $23C0: TL=0, TR=1, BL=2, BR=3 → $E4
    LDA #$23
    STA PPUADDR
    LDA #$C0
    STA PPUADDR
    LDA #$E4               ; %11_10_01_00
    STA PPUDATA

    ; Attribute byte 1 at $23C1: all quadrants = palette 2 → $AA
    LDA #$23
    STA PPUADDR
    LDA #$C1
    STA PPUADDR
    LDA #$AA               ; %10_10_10_10
    STA PPUDATA

    ; --- Enable rendering ---
    BIT PPUSTATUS
    LDA #$00
    STA PPUADDR
    STA PPUADDR

    LDA #%10000000         ; Enable NMI, BG pattern table 0
    STA PPUCTRL
    LDA #%00001010         ; Show background
    STA PPUMASK

loop:
    JMP loop

nmi_handler:
irq_handler:
    RTI

.segment "VECTORS"
    .word nmi_handler, reset, irq_handler

.segment "CHARS"
    .incbin "tiles.chr"
