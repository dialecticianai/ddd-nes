; chrram.s — CHR-RAM tile copy test ROM
;
; Copies 4 tile definitions from PRG-ROM (RODATA) to CHR-RAM pattern
; table ($0000-$003F) via PPUADDR/PPUDATA, then displays them in the
; nametable.
;
; Tile definitions (16 bytes each):
;   Tile $00: solid fill (all pixels = color 1)
;   Tile $01: checkerboard (alternating 0 and 1)
;   Tile $02: horizontal stripes (rows alternate 0 and 2)
;   Tile $03: solid fill (all pixels = color 3)
;
; Nametable placements:
;   (5, 3) → tile $00
;   (10, 7) → tile $01
;   (15, 5) → tile $02
;   (20, 10) → tile $03
;
; RAM:
;   $10: frame_counter

PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
PPUADDR   = $2006
PPUDATA   = $2007

.segment "HEADER"
    .byte "NES", $1A
    .byte $01              ; 1x 16KB PRG-ROM
    .byte $00              ; 0 CHR-ROM banks = CHR-RAM
    .byte $00, $00         ; Mapper 0, horizontal mirroring
    .res 8, $00

.segment "ZEROPAGE"
    frame_counter: .res 1  ; $10

.segment "RODATA"

; 4 tile definitions, 16 bytes each = 64 bytes total
tile_data:
; Tile 0: solid color 1 (plane0 = $FF, plane1 = $00)
    .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; plane 0
    .byte $00,$00,$00,$00,$00,$00,$00,$00  ; plane 1

; Tile 1: checkerboard (alternating pixels)
    .byte $55,$AA,$55,$AA,$55,$AA,$55,$AA  ; plane 0
    .byte $00,$00,$00,$00,$00,$00,$00,$00  ; plane 1

; Tile 2: horizontal stripes color 2 (plane0 = $00, plane1 = $FF/$00)
    .byte $00,$00,$00,$00,$00,$00,$00,$00  ; plane 0
    .byte $FF,$00,$FF,$00,$FF,$00,$FF,$00  ; plane 1

; Tile 3: solid color 3 (both planes = $FF)
    .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; plane 0
    .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; plane 1

TILE_COUNT = 4
TILE_SIZE  = 16
TOTAL_BYTES = TILE_COUNT * TILE_SIZE  ; 64

.segment "CODE"

reset:
    SEI
    CLD
    LDX #$FF
    TXS

    LDA #$00
    STA frame_counter
    STA PPUCTRL
    STA PPUMASK
    BIT PPUSTATUS

vblankwait1:
    BIT PPUSTATUS
    BPL vblankwait1
vblankwait2:
    BIT PPUSTATUS
    BPL vblankwait2

    ; --- Copy tiles from PRG-ROM to CHR-RAM ---
    ; Set PPUADDR to $0000 (pattern table 0, tile 0)
    BIT PPUSTATUS
    LDA #$00
    STA PPUADDR
    STA PPUADDR

    ; Copy 64 bytes (4 tiles x 16 bytes)
    LDX #0
copy_tiles:
    LDA tile_data, X
    STA PPUDATA
    INX
    CPX #TOTAL_BYTES
    BNE copy_tiles

    ; --- Load palette ---
    BIT PPUSTATUS
    LDA #$3F
    STA PPUADDR
    LDA #$00
    STA PPUADDR

    ; Palette 0: black, red, blue, white
    LDA #$0F               ; black
    STA PPUDATA
    LDA #$16               ; red
    STA PPUDATA
    LDA #$12               ; blue
    STA PPUDATA
    LDA #$30               ; white
    STA PPUDATA

    ; --- Write tiles to nametable ---
    ; (5, 3) → tile $00: $2000 + 3*32 + 5 = $2065
    BIT PPUSTATUS
    LDA #$20
    STA PPUADDR
    LDA #$65
    STA PPUADDR
    LDA #$00
    STA PPUDATA

    ; (10, 7) → tile $01: $2000 + 7*32 + 10 = $20EA
    LDA #$20
    STA PPUADDR
    LDA #$EA
    STA PPUADDR
    LDA #$01
    STA PPUDATA

    ; (15, 5) → tile $02: $2000 + 5*32 + 15 = $20AF
    LDA #$20
    STA PPUADDR
    LDA #$AF
    STA PPUADDR
    LDA #$02
    STA PPUDATA

    ; (20, 10) → tile $03: $2000 + 10*32 + 20 = $2154
    LDA #$21
    STA PPUADDR
    LDA #$54
    STA PPUADDR
    LDA #$03
    STA PPUDATA

    ; --- Enable rendering ---
    BIT PPUSTATUS
    LDA #$00
    STA PPUADDR
    STA PPUADDR

    LDA #%10000000         ; NMI on
    STA PPUCTRL
    LDA #%00001010         ; Show background
    STA PPUMASK

loop:
    JMP loop

nmi_handler:
    INC frame_counter
    RTI

irq_handler:
    RTI

.segment "VECTORS"
    .word nmi_handler, reset, irq_handler
