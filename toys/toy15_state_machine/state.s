; state.s — Game state machine test ROM
;
; 3 states: MENU (0), GAMEPLAY (1), PAUSED (2)
; Transitions via Start button (edge detection):
;   MENU → GAMEPLAY → PAUSED → GAMEPLAY → ...
;
; NMI handler: read controller, detect new presses, dispatch state update
;
; RAM layout (zero page):
;   $10: game_state    (0=menu, 1=gameplay, 2=paused)
;   $11: frame_counter (increments each NMI)
;   $12: buttons       (current frame, all 8 buttons packed)
;   $13: buttons_prev  (previous frame)
;   $14: buttons_new   (newly pressed this frame)

STATE_MENU     = 0
STATE_GAMEPLAY = 1
STATE_PAUSED   = 2

BTN_START = %00010000   ; Start is bit 4 (A=80, B=40, Select=20, Start=10)

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
    STX $2000
    STX $2001
    BIT $2002

    ; Initialize game state
    LDA #STATE_MENU
    STA $10                ; game_state = MENU
    LDA #0
    STA $11                ; frame_counter = 0
    STA $12                ; buttons = 0
    STA $13                ; buttons_prev = 0
    STA $14                ; buttons_new = 0

    ; Wait 2 vblanks
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
nmi_handler:
    PHA
    TXA
    PHA
    TYA
    PHA

    ; Increment frame counter
    INC $11

    ; Save previous buttons
    LDA $12
    STA $13                ; buttons_prev = buttons

    ; Read controller 1
    JSR read_controller

    ; Detect new presses: buttons AND NOT buttons_prev
    LDA $12
    EOR $13                ; bits that changed
    AND $12                ; only bits that are now pressed (not released)
    STA $14                ; buttons_new

    ; Check for Start press
    LDA $14
    AND #BTN_START
    BEQ @no_start

    ; Start was newly pressed — transition state
    LDA $10                ; game_state
    CMP #STATE_MENU
    BEQ @menu_to_gameplay
    CMP #STATE_GAMEPLAY
    BEQ @gameplay_to_paused
    CMP #STATE_PAUSED
    BEQ @paused_to_gameplay
    JMP @no_start          ; unknown state, ignore

@menu_to_gameplay:
    LDA #STATE_GAMEPLAY
    STA $10
    JMP @no_start

@gameplay_to_paused:
    LDA #STATE_PAUSED
    STA $10
    JMP @no_start

@paused_to_gameplay:
    LDA #STATE_GAMEPLAY
    STA $10

@no_start:
    PLA
    TAY
    PLA
    TAX
    PLA
    RTI

; === Controller Read ===
; Reads 8 buttons into $12 (A=80, B=40, Sel=20, Start=10, U=08, D=04, L=02, R=01)
read_controller:
    LDA #$01
    STA $4016              ; Strobe
    LDA #$00
    STA $4016              ; Latch

    LDX #8
@read_loop:
    LDA $4016              ; Read next button (bit 0)
    LSR                    ; Shift bit 0 into carry
    ROL $12                ; Rotate carry into buttons byte
    DEX
    BNE @read_loop
    RTS

irq_handler:
    RTI

.segment "VECTORS"
    .word nmi_handler, reset, irq_handler

.segment "CHARS"
    .res 8192, $00
