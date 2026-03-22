; entity.s — Entity/sprite management test ROM
;
; 4 entities stored as array-of-structs at $0300 (8 bytes each).
; NMI handler copies entity positions to shadow OAM ($0200) and triggers DMA.
;
; Entity record layout (8 bytes):
;   +0: x_pos    +1: y_pos    +2: tile    +3: attr
;   +4: type     +5: state    +6: pad0    +7: pad1
;
; OAM sprite layout (4 bytes):
;   +0: Y    +1: tile    +2: attr    +3: X
;
; Zero page:
;   $10: entity_count    $11: frame_counter

NUM_ENTITIES = 4
ENT_STRIDE   = 8          ; bytes per entity record
OAM_STRIDE   = 4          ; bytes per OAM sprite entry

; Entity field offsets
ENT_X     = 0
ENT_Y     = 1
ENT_TILE  = 2
ENT_ATTR  = 3
ENT_TYPE  = 4
ENT_STATE = 5

.segment "ZEROPAGE"
entity_count: .res 1       ; $10
frame_counter: .res 1      ; $11

.segment "HEADER"
    .byte "NES", $1A
    .byte $01, $01, $00, $00
    .res 8, $00

.segment "CODE"

reset:
    SEI
    CLD
    LDX #$FF
    TXS

    INX                    ; X = 0
    STX $2000              ; PPUCTRL = 0
    STX $2001              ; PPUMASK = 0
    BIT $2002              ; Clear vblank flag

    ; Clear shadow OAM — hide all sprites (Y=$FF)
    LDA #$FF
    LDX #0
@clear_oam:
    STA $0200, X
    INX
    BNE @clear_oam

    ; Initialize entity count and frame counter
    LDA #NUM_ENTITIES
    STA entity_count
    LDA #0
    STA frame_counter

    ; === Initialize 4 entities at $0300 ===

    ; Entity 0: x=32, y=40, tile=$01, attr=$00, type=1, state=0
    LDA #32
    STA $0300 + ENT_X
    LDA #40
    STA $0300 + ENT_Y
    LDA #$01
    STA $0300 + ENT_TILE
    LDA #$00
    STA $0300 + ENT_ATTR
    LDA #1
    STA $0300 + ENT_TYPE
    LDA #0
    STA $0300 + ENT_STATE
    STA $0300 + 6           ; pad0
    STA $0300 + 7           ; pad1

    ; Entity 1: x=80, y=60, tile=$02, attr=$00, type=1, state=0
    LDA #80
    STA $0308 + ENT_X
    LDA #60
    STA $0308 + ENT_Y
    LDA #$02
    STA $0308 + ENT_TILE
    LDA #$00
    STA $0308 + ENT_ATTR
    LDA #1
    STA $0308 + ENT_TYPE
    LDA #0
    STA $0308 + ENT_STATE
    STA $0308 + 6
    STA $0308 + 7

    ; Entity 2: x=128, y=100, tile=$03, attr=$01, type=1, state=0
    LDA #128
    STA $0310 + ENT_X
    LDA #100
    STA $0310 + ENT_Y
    LDA #$03
    STA $0310 + ENT_TILE
    LDA #$01
    STA $0310 + ENT_ATTR
    LDA #1
    STA $0310 + ENT_TYPE
    LDA #0
    STA $0310 + ENT_STATE
    STA $0310 + 6
    STA $0310 + 7

    ; Entity 3: x=200, y=150, tile=$04, attr=$02, type=1, state=0
    LDA #200
    STA $0318 + ENT_X
    LDA #150
    STA $0318 + ENT_Y
    LDA #$04
    STA $0318 + ENT_TILE
    LDA #$02
    STA $0318 + ENT_ATTR
    LDA #1
    STA $0318 + ENT_TYPE
    LDA #0
    STA $0318 + ENT_STATE
    STA $0318 + 6
    STA $0318 + 7

    ; Wait 2 vblanks for PPU warmup
vblankwait1:
    BIT $2002
    BPL vblankwait1
vblankwait2:
    BIT $2002
    BPL vblankwait2

    ; Enable NMI (bit 7 of PPUCTRL)
    LDA #%10000000
    STA $2000

loop:
    JMP loop

; === NMI Handler ===
; Copies entity positions to shadow OAM, then triggers OAM DMA
nmi_handler:
    PHA
    TXA
    PHA
    TYA
    PHA

    ; Increment frame counter
    INC frame_counter

    ; === Entity → OAM sync ===
    ; X indexes into entity table (stride 8)
    ; Y indexes into OAM shadow (stride 4)
    LDX #0                 ; entity table offset
    LDY #0                 ; OAM offset

@sync_loop:
    ; OAM byte 0: Y position (from entity +1)
    LDA $0300 + ENT_Y, X
    STA $0200, Y
    INY

    ; OAM byte 1: tile index (from entity +2)
    LDA $0300 + ENT_TILE, X
    STA $0200, Y
    INY

    ; OAM byte 2: attributes (from entity +3)
    LDA $0300 + ENT_ATTR, X
    STA $0200, Y
    INY

    ; OAM byte 3: X position (from entity +0)
    LDA $0300 + ENT_X, X
    STA $0200, Y
    INY

    ; Advance to next entity (stride 8)
    TXA
    CLC
    ADC #ENT_STRIDE
    TAX

    ; Check if we've done all entities (4 * 8 = 32)
    CPX #(NUM_ENTITIES * ENT_STRIDE)
    BNE @sync_loop

    ; Trigger OAM DMA
    LDA #0
    STA $2003              ; OAMADDR = 0
    LDA #$02
    STA $4014              ; DMA from $0200

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
    .res 8192, $00
