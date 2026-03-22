; meta.s — Metatile decompression test ROM
;
; Defines a metatile table (4 entries, 8 bytes each) and a level data
; row (4 metatile IDs). Decompresses to nametable + attribute table.
;
; Metatile table format (8 bytes per entry, power-of-2 for easy indexing):
;   Byte 0: top-left tile
;   Byte 1: top-right tile
;   Byte 2: bottom-left tile
;   Byte 3: bottom-right tile
;   Byte 4: palette (0-3)
;   Bytes 5-7: padding
;
; Level data: 4 metatile IDs → 4 metatiles across (8 tiles wide, 2 tiles tall)
;
; Decompression target: nametable $2000, starting at (0, 0)
;
; --- Expected nametable output ---
;   Row 0: MT0.TL MT0.TR MT1.TL MT1.TR MT2.TL MT2.TR MT3.TL MT3.TR
;   Row 1: MT0.BL MT0.BR MT1.BL MT1.BR MT2.BL MT2.BR MT3.BL MT3.BR
;
; Metatile definitions (using tiles from tiles.png):
;   MT0: tiles $01,$02,$03,$04, palette 0  (solid gray + checkerboard)
;   MT1: tiles $05,$06,$07,$01, palette 1  (stripes + solid)
;   MT2: tiles $02,$03,$04,$05, palette 2  (mixed)
;   MT3: tiles $06,$07,$01,$02, palette 3  (mixed)
;
; Attribute byte $23C0 covers cols 0-3, rows 0-3:
;   TL quadrant (cols 0-1, rows 0-1) = MT0 palette = 0
;   TR quadrant (cols 2-3, rows 0-1) = MT1 palette = 1
;   BL quadrant (cols 0-1, rows 2-3) = unused (0)
;   BR quadrant (cols 2-3, rows 2-3) = unused (0)
;   → attribute byte = (0 << 6) | (0 << 4) | (1 << 2) | 0 = $04
;
; Attribute byte $23C1 covers cols 4-7, rows 0-3:
;   TL quadrant (cols 4-5, rows 0-1) = MT2 palette = 2
;   TR quadrant (cols 6-7, rows 0-1) = MT3 palette = 3
;   BL quadrant (cols 4-5, rows 2-3) = unused (0)
;   BR quadrant (cols 6-7, rows 2-3) = unused (0)
;   → attribute byte = (0 << 6) | (0 << 4) | (3 << 2) | 2 = $0E

PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
PPUADDR   = $2006
PPUDATA   = $2007

.segment "HEADER"
    .byte "NES", $1A
    .byte $01              ; 1x 16KB PRG-ROM
    .byte $01              ; 1x 8KB CHR-ROM
    .byte $00
    .byte $00
    .res 8, $00

.segment "ZEROPAGE"
    mt_index:  .res 1      ; Current metatile index in level data
    mt_offset: .res 1      ; Offset into metatile table (index * 8)
    nt_lo:     .res 1      ; Nametable address low byte (row 0)
    attr_val:  .res 1      ; Accumulated attribute byte

.segment "RODATA"

; Metatile table: 4 entries x 8 bytes = 32 bytes
metatile_table:
    ; MT0: palette 0
    .byte $01, $02, $03, $04  ; TL, TR, BL, BR
    .byte $00                  ; palette
    .byte $00, $00, $00        ; padding
    ; MT1: palette 1
    .byte $05, $06, $07, $01
    .byte $01
    .byte $00, $00, $00
    ; MT2: palette 2
    .byte $02, $03, $04, $05
    .byte $02
    .byte $00, $00, $00
    ; MT3: palette 3
    .byte $06, $07, $01, $02
    .byte $03
    .byte $00, $00, $00

; Level data: 4 metatile IDs
level_data:
    .byte $00, $01, $02, $03   ; MT0, MT1, MT2, MT3
LEVEL_WIDTH = 4

.segment "CODE"

reset:
    SEI
    CLD
    LDX #$FF
    TXS

    INX
    STX PPUCTRL
    STX PPUMASK
    BIT PPUSTATUS

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
    STA PPUADDR

    ; Palette 0: black, red, dark red, white
    LDA #$0F
    STA PPUDATA
    LDA #$16
    STA PPUDATA
    LDA #$06
    STA PPUDATA
    LDA #$30
    STA PPUDATA

    ; Palette 1: black, green, dark green, light green
    LDA #$0F
    STA PPUDATA
    LDA #$1A
    STA PPUDATA
    LDA #$0A
    STA PPUDATA
    LDA #$2A
    STA PPUDATA

    ; Palette 2: black, blue, dark blue, light blue
    LDA #$0F
    STA PPUDATA
    LDA #$12
    STA PPUDATA
    LDA #$02
    STA PPUDATA
    LDA #$22
    STA PPUDATA

    ; Palette 3: black, purple, dark purple, light purple
    LDA #$0F
    STA PPUDATA
    LDA #$14
    STA PPUDATA
    LDA #$04
    STA PPUDATA
    LDA #$24
    STA PPUDATA

    ; --- Decompress metatiles to nametable ---
    ; Process each metatile in level_data
    LDA #0
    STA mt_index
    STA nt_lo               ; Start at nametable col 0
    STA attr_val             ; Clear attribute accumulator

decompress_loop:
    ; Calculate metatile table offset: mt_index * 8
    ; Load metatile ID from level data
    LDX mt_index
    LDA level_data, X
    ; Multiply by 8 (shift left 3)
    ASL
    ASL
    ASL
    STA mt_offset

    ; --- Write top-left and top-right tiles (row 0) ---
    ; Nametable address = $2000 + nt_lo
    BIT PPUSTATUS
    LDA #$20
    STA PPUADDR
    LDA nt_lo
    STA PPUADDR

    LDX mt_offset
    LDA metatile_table, X     ; TL tile
    STA PPUDATA
    LDA metatile_table+1, X   ; TR tile
    STA PPUDATA

    ; --- Write bottom-left and bottom-right tiles (row 1) ---
    ; Nametable address = $2020 + nt_lo (row 1 = row 0 + 32)
    LDA #$20
    STA PPUADDR
    LDA nt_lo
    CLC
    ADC #$20                  ; Add 32 for next row
    STA PPUADDR

    LDX mt_offset
    LDA metatile_table+2, X   ; BL tile
    STA PPUDATA
    LDA metatile_table+3, X   ; BR tile
    STA PPUDATA

    ; --- Accumulate attribute bits ---
    ; Each metatile occupies one quadrant of an attribute byte.
    ; Metatiles 0,1 share attribute byte $23C0 (TL, TR quadrants)
    ; Metatiles 2,3 share attribute byte $23C1 (TL, TR quadrants)
    ; Within each pair: first = TL (bits 1-0), second = TR (bits 3-2)
    LDX mt_offset
    LDA metatile_table+4, X   ; palette value (0-3)

    ; Determine position within attribute byte pair
    LDY mt_index
    TYA
    AND #$01                  ; 0 = TL quadrant, 1 = TR quadrant
    BNE @tr_quadrant

@tl_quadrant:
    ; TL: palette in bits 1-0 (no shift needed)
    LDA metatile_table+4, X
    ORA attr_val
    STA attr_val
    JMP @attr_done

@tr_quadrant:
    ; TR: palette in bits 3-2 (shift left 2)
    LDA metatile_table+4, X
    ASL
    ASL
    ORA attr_val
    STA attr_val

    ; We've filled both quadrants — write attribute byte
    ; Attribute address: $23C0 + (mt_index / 2) - 1... actually:
    ; mt_index=1 → write $23C0, mt_index=3 → write $23C1
    LDA #$23
    STA PPUADDR
    TYA                       ; mt_index (1 or 3)
    LSR                       ; divide by 2 (0 or 1)
    CLC
    ADC #$C0
    STA PPUADDR
    LDA attr_val
    STA PPUDATA

    ; Reset accumulator for next pair
    LDA #0
    STA attr_val

@attr_done:
    ; Advance to next metatile
    LDA nt_lo
    CLC
    ADC #2                    ; Each metatile = 2 tiles wide
    STA nt_lo

    INC mt_index
    LDA mt_index
    CMP #LEVEL_WIDTH
    BEQ decompress_done
    JMP decompress_loop
decompress_done:

    ; --- Enable rendering ---
    BIT PPUSTATUS
    LDA #$00
    STA PPUADDR
    STA PPUADDR

    LDA #%10000000
    STA PPUCTRL
    LDA #%00001010
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
