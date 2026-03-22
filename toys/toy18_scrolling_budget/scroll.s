; scroll.s — Horizontal scrolling with nametable column streaming
;
; Phase 2 toy: validates that OAM DMA + 30-tile column write + scroll
; all fit within the vblank budget, verified via cycle counting.
;
; RAM layout:
;   $10: scroll_x
;   $11: frame_counter
;   $12: columns_written
;   $13: need_column (flag)
;   $14: column_index (0-31)
;   $15: prev_scroll_col
;   $16-$17: addr_ptr (16-bit temp for column address calculation)

PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014

.segment "HEADER"
    .byte "NES", $1A
    .byte $01, $01, $00, $00
    .res 8, $00

.segment "ZEROPAGE"
    scroll_x:        .res 1   ; $10
    frame_counter:   .res 1   ; $11
    columns_written: .res 1   ; $12
    need_column:     .res 1   ; $13
    column_index:    .res 1   ; $14
    prev_scroll_col: .res 1   ; $15
    addr_lo:         .res 1   ; $16
    addr_hi:         .res 1   ; $17

.segment "CODE"

reset:
    SEI
    CLD
    LDX #$FF
    TXS

    LDA #$00
    STA scroll_x
    STA frame_counter
    STA columns_written
    STA need_column
    STA column_index
    STA prev_scroll_col

    STA PPUCTRL
    STA PPUMASK
    BIT PPUSTATUS

vblankwait1:
    BIT PPUSTATUS
    BPL vblankwait1
vblankwait2:
    BIT PPUSTATUS
    BPL vblankwait2

    ; Fill nametable 0 with tile $01 (1024 bytes)
    BIT PPUSTATUS
    LDA #$20
    STA PPUADDR
    LDA #$00
    STA PPUADDR
    LDY #0
    LDX #4
fill:
    LDA #$01
    STA PPUDATA
    INY
    BNE fill
    DEX
    BNE fill

    ; Enable NMI + BG rendering
    LDA #%10000000
    STA PPUCTRL
    LDA #%00001010
    STA PPUMASK

loop:
    JMP loop

; === NMI Handler ===
nmi_handler:
    PHA
    TXA
    PHA
    TYA
    PHA

    ; OAM DMA
    LDA #$00
    STA OAMADDR
    LDA #$02
    STA OAMDMA

    ; Increment counters
    INC frame_counter
    INC scroll_x

    ; Check 8-pixel boundary crossing
    LDA scroll_x
    LSR
    LSR
    LSR                   ; scroll_x / 8
    CMP prev_scroll_col
    BEQ @no_column
    STA prev_scroll_col
    ; Column to write = (scroll_col + 2) mod 32
    CLC
    ADC #2
    AND #$1F
    STA column_index
    LDA #1
    STA need_column
@no_column:

    ; Write column if needed
    LDA need_column
    BEQ @skip_column

    ; Calculate base address for column: $2000 + column_index
    LDA #$00
    STA addr_lo
    LDA #$20
    STA addr_hi
    ; addr = $2000 + column_index
    LDA addr_lo
    CLC
    ADC column_index
    STA addr_lo

    ; Write 30 tiles down the column
    LDX #0
@write_col:
    BIT PPUSTATUS         ; reset latch
    LDA addr_hi
    STA PPUADDR
    LDA addr_lo
    STA PPUADDR
    LDA #$02              ; write tile $02 (distinct from fill $01)
    STA PPUDATA

    ; Advance address by 32 (next row)
    LDA addr_lo
    CLC
    ADC #32
    STA addr_lo
    LDA addr_hi
    ADC #0                ; carry from low byte
    STA addr_hi

    INX
    CPX #30
    BNE @write_col

    INC columns_written
    LDA #0
    STA need_column

@skip_column:
    ; Update scroll registers
    BIT PPUSTATUS
    LDA scroll_x
    STA PPUSCROLL
    LDA #0
    STA PPUSCROLL

    LDA #%10000000
    STA PPUCTRL

    PLA
    TAY
    PLA
    TAX
    PLA
    RTI

irq_handler:
    RTI

.segment "VECTORS"
    .word nmi_handler, reset, irq_handler

.segment "CHARS"
    .incbin "tiles.chr"
