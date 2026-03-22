; collide.s — AABB collision detection test ROM
;
; Two entities with 8x8 bounding boxes. NMI sequences 3 scenarios:
;   Scenario 1: overlapping  → result $10 = 1
;   Scenario 2: far apart    → result $11 = 0
;   Scenario 3: edge touch   → result $12 = 1
;
; Entity A fixed at (80, 80). Entity B repositioned each scenario.
;
; AABB overlap: |A.x - B.x| < 8 AND |A.y - B.y| < 8
;
; Zero page layout:
;   $10: result1   $11: result2   $12: result3   $13: frame_counter
;   $20: A.x       $21: A.y       $22: B.x       $23: B.y

BOX_SIZE = 8               ; bounding box width/height (8x8 sprites)

.segment "ZEROPAGE"
result1:       .res 1      ; $10 — scenario 1 (overlap)
result2:       .res 1      ; $11 — scenario 2 (far apart)
result3:       .res 1      ; $12 — scenario 3 (edge touch)
frame_counter: .res 1      ; $13

.res 12                    ; pad $14-$1F

entity_ax:     .res 1      ; $20
entity_ay:     .res 1      ; $21
entity_bx:     .res 1      ; $22
entity_by:     .res 1      ; $23

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

    ; Clear zero page results and counter
    LDA #0
    STA result1
    STA result2
    STA result3
    STA frame_counter

    ; Entity A: fixed at (80, 80)
    LDA #80
    STA entity_ax
    STA entity_ay

    ; Entity B: will be set per scenario in NMI
    LDA #0
    STA entity_bx
    STA entity_by

    ; Wait 2 vblanks for PPU warmup
vblankwait1:
    BIT $2002
    BPL vblankwait1
vblankwait2:
    BIT $2002
    BPL vblankwait2

    ; Enable NMI
    LDA #%10000000
    STA $2000

loop:
    JMP loop

; === NMI Handler ===
; Sequences through 3 collision scenarios, one per frame.
nmi_handler:
    PHA
    TXA
    PHA

    ; Increment frame counter
    INC frame_counter
    LDA frame_counter

    ; Dispatch based on frame counter
    CMP #1
    BEQ scenario1
    CMP #2
    BEQ scenario2
    CMP #3
    BEQ scenario3
    JMP nmi_done           ; frames > 3: no-op

scenario1:
    ; Entity B at (84, 83) — overlapping (dx=4 < 8, dy=3 < 8)
    LDA #84
    STA entity_bx
    LDA #83
    STA entity_by
    JSR check_aabb
    STA result1
    JMP nmi_done

scenario2:
    ; Entity B at (200, 200) — far apart (dx=120, dy=120)
    LDA #200
    STA entity_bx
    LDA #200
    STA entity_by
    JSR check_aabb
    STA result2
    JMP nmi_done

scenario3:
    ; Entity B at (87, 80) — edge touching (dx=7 < 8, dy=0 < 8)
    LDA #87
    STA entity_bx
    LDA #80
    STA entity_by
    JSR check_aabb
    STA result3
    JMP nmi_done

nmi_done:
    PLA
    TAX
    PLA
    RTI

; === check_aabb ===
; AABB collision between entity A and entity B (8x8 boxes).
; Reads: entity_ax, entity_ay, entity_bx, entity_by
; Returns: A = 1 if collision, A = 0 if no collision.
; Clobbers: A, X (X used as temp)
check_aabb:
    ; --- Check X axis: |A.x - B.x| < BOX_SIZE ---
    LDA entity_ax
    SEC
    SBC entity_bx          ; A = A.x - B.x (unsigned)
    BCS @x_pos             ; If carry set, result >= 0 (A.x >= B.x)
    ; A.x < B.x: result is negative (two's complement). Negate it.
    EOR #$FF
    CLC
    ADC #1                 ; A = |A.x - B.x|
@x_pos:
    CMP #BOX_SIZE
    BCS @no_collision      ; |dx| >= 8 → no collision

    ; --- Check Y axis: |A.y - B.y| < BOX_SIZE ---
    LDA entity_ay
    SEC
    SBC entity_by          ; A = A.y - B.y
    BCS @y_pos
    EOR #$FF
    CLC
    ADC #1                 ; A = |A.y - B.y|
@y_pos:
    CMP #BOX_SIZE
    BCS @no_collision      ; |dy| >= 8 → no collision

    ; Both axes overlap — collision!
    LDA #1
    RTS

@no_collision:
    LDA #0
    RTS

irq_handler:
    RTI

.segment "VECTORS"
    .word nmi_handler, reset, irq_handler

.segment "CHARS"
    .res 8192, $00
