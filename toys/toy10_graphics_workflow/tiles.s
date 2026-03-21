; tiles.s — Graphics asset pipeline test ROM
;
; Displays custom tiles from PNG-converted CHR-ROM data.
; Verifies: palette loading, nametable tile placement, CHR-ROM inclusion.
;
; Tile map (from tiles.png):
;   $00 = blank (black)
;   $01 = solid dark gray
;   $02 = solid light gray
;   $03 = solid white
;   $04 = checkerboard
;   $05 = diagonal stripes
;   $06 = horizontal stripes
;   $07 = border frame

PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
PPUADDR   = $2006
PPUDATA   = $2007

; --- Nametable tile placements (documented for tests) ---
; Position (col, row) → tile index
;   ( 5,  3) → $01  (solid dark gray)
;   (10,  7) → $02  (solid light gray)
;   (15,  5) → $03  (solid white)
;   (20, 10) → $04  (checkerboard)
;   ( 8, 15) → $05  (diagonal stripes)
;   (25, 20) → $06  (horizontal stripes)
;   (12, 25) → $07  (border frame)

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

    ; --- Load palette ---
    BIT PPUSTATUS          ; Reset address latch
    LDA #$3F
    STA PPUADDR
    LDA #$00
    STA PPUADDR            ; Address = $3F00

    ; Background palette 0: black, dark blue, light blue, white
    LDA #$0F               ; $3F00: black
    STA PPUDATA
    LDA #$12               ; $3F01: dark blue
    STA PPUDATA
    LDA #$21               ; $3F02: light blue
    STA PPUDATA
    LDA #$30               ; $3F03: white
    STA PPUDATA

    ; --- Write tiles to nametable ---
    ; Nametable $2000: each row = 32 tiles
    ; Address = $2000 + (row * 32) + col

    ; Tile $01 at (5, 3): $2000 + 3*32 + 5 = $2000 + 96 + 5 = $2065
    BIT PPUSTATUS
    LDA #$20
    STA PPUADDR
    LDA #$65
    STA PPUADDR
    LDA #$01
    STA PPUDATA

    ; Tile $02 at (10, 7): $2000 + 7*32 + 10 = $2000 + 224 + 10 = $20EA
    LDA #$20
    STA PPUADDR
    LDA #$EA
    STA PPUADDR
    LDA #$02
    STA PPUDATA

    ; Tile $03 at (15, 5): $2000 + 5*32 + 15 = $2000 + 160 + 15 = $20AF
    LDA #$20
    STA PPUADDR
    LDA #$AF
    STA PPUADDR
    LDA #$03
    STA PPUDATA

    ; Tile $04 at (20, 10): $2000 + 10*32 + 20 = $2000 + 320 + 20 = $2154
    LDA #$21
    STA PPUADDR
    LDA #$54
    STA PPUADDR
    LDA #$04
    STA PPUDATA

    ; Tile $05 at (8, 15): $2000 + 15*32 + 8 = $2000 + 480 + 8 = $21E8
    LDA #$21
    STA PPUADDR
    LDA #$E8
    STA PPUADDR
    LDA #$05
    STA PPUDATA

    ; Tile $06 at (25, 20): $2000 + 20*32 + 25 = $2000 + 640 + 25 = $2299
    LDA #$22
    STA PPUADDR
    LDA #$99
    STA PPUADDR
    LDA #$06
    STA PPUDATA

    ; Tile $07 at (12, 25): $2000 + 25*32 + 12 = $2000 + 800 + 12 = $232C
    LDA #$23
    STA PPUADDR
    LDA #$2C
    STA PPUADDR
    LDA #$07
    STA PPUDATA

    ; --- Enable rendering ---
    BIT PPUSTATUS          ; Reset address latch
    LDA #$00
    STA PPUADDR
    STA PPUADDR            ; Reset scroll via PPUADDR

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
