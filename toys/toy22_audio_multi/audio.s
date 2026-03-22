; audio.s — Multi-channel audio + SFX priority test ROM
;
; 3 channels playing simultaneously:
;   Pulse 1 ($4000): 400 Hz (continuous "music")
;   Pulse 2 ($4004): 300 Hz (music, interrupted by SFX)
;   Triangle ($4008): 200 Hz (continuous "bass")
;
; SFX system: at frame 20, trigger SFX on pulse 2 (800 Hz beep for 10 frames).
; When SFX expires, pulse 2 returns to 300 Hz.
;
; RAM layout:
;   $10: sfx_active      (countdown timer, 0 = no SFX)
;   $11: sfx_trigger     (write 1 to start SFX)
;   $12: frame_counter
;   $13: sfx_completed   (set 1 when SFX finishes)

; Period constants
; Pulse: period = 111860.8 / freq - 1
; Triangle: period = 55930.4 / freq - 1
PULSE1_PERIOD  = 279       ; 400 Hz
PULSE2_PERIOD  = 372       ; 300 Hz (111860.8/300 - 1 ≈ 372)
TRI_PERIOD     = 279       ; 200 Hz (55930.4/200 - 1 ≈ 279)
SFX_PERIOD     = 139       ; 800 Hz pulse

SFX_DURATION   = 10        ; frames

.segment "HEADER"
    .byte "NES", $1A
    .byte $01, $01, $00, $00
    .res 8, $00

.segment "ZEROPAGE"
    sfx_active:    .res 1  ; $10
    sfx_trigger:   .res 1  ; $11
    frame_counter: .res 1  ; $12
    sfx_completed: .res 1  ; $13

.segment "CODE"

reset:
    SEI
    CLD
    LDX #$FF
    TXS

    LDA #$00
    STA sfx_active
    STA sfx_trigger
    STA frame_counter
    STA sfx_completed
    STA $2000
    STA $2001
    BIT $2002

vblankwait1:
    BIT $2002
    BPL vblankwait1
vblankwait2:
    BIT $2002
    BPL vblankwait2

    ; --- Initialize APU ---
    JSR init_apu

    ; --- Set up 3 channels ---

    ; Pulse 1: 400 Hz, 50% duty, max volume
    LDA #%10111111         ; duty 50%, constant volume, vol=15
    STA $4000
    LDA #<PULSE1_PERIOD
    STA $4002
    LDA #>PULSE1_PERIOD
    STA $4003

    ; Pulse 2: 300 Hz, 25% duty, max volume
    LDA #%01111111         ; duty 25%, constant volume, vol=15
    STA $4004
    LDA #<PULSE2_PERIOD
    STA $4006
    LDA #>PULSE2_PERIOD
    STA $4007

    ; Triangle: 200 Hz
    LDA #%11000000         ; Un-mute, length counter load
    STA $4008
    LDA #<TRI_PERIOD
    STA $400A
    LDA #>TRI_PERIOD
    STA $400B

    ; Enable NMI
    LDA #%10000000
    STA $2000

loop:
    ; Trigger SFX at frame 20
    LDA frame_counter
    CMP #20
    BNE loop
    LDA sfx_trigger        ; Only trigger once
    BNE loop
    LDA sfx_completed
    BNE loop
    LDA #1
    STA sfx_trigger
    JMP loop

; === NMI Handler ===
nmi_handler:
    PHA
    TXA
    PHA

    INC frame_counter

    ; --- Check SFX trigger ---
    LDA sfx_trigger
    BEQ @check_sfx_active
    ; Start SFX: switch pulse 2 to 800 Hz
    LDA #SFX_DURATION
    STA sfx_active
    LDA #0
    STA sfx_trigger        ; consume trigger
    ; Set pulse 2 to SFX tone
    LDA #%10111111         ; 50% duty, max volume (louder for SFX)
    STA $4004
    LDA #<SFX_PERIOD
    STA $4006
    LDA #>SFX_PERIOD
    STA $4007
    JMP @nmi_done

@check_sfx_active:
    LDA sfx_active
    BEQ @nmi_done
    ; SFX countdown
    DEC sfx_active
    BNE @nmi_done
    ; SFX expired — restore pulse 2 to music
    LDA #%01111111         ; 25% duty, max volume
    STA $4004
    LDA #<PULSE2_PERIOD
    STA $4006
    LDA #>PULSE2_PERIOD
    STA $4007
    LDA #1
    STA sfx_completed

@nmi_done:
    PLA
    TAX
    PLA
    RTI

; === APU Init (from toy6/learnings) ===
init_apu:
    LDY #$13
@loop:
    LDA @regs, Y
    STA $4000, Y
    DEY
    BPL @loop
    LDA #$0F
    STA $4015              ; Enable all channels
    LDA #$40
    STA $4017              ; Disable IRQ
    RTS
@regs:
    .byte $30,$08,$00,$00  ; Pulse 1
    .byte $30,$08,$00,$00  ; Pulse 2
    .byte $80,$00,$00,$00  ; Triangle
    .byte $30,$00,$00,$00  ; Noise
    .byte $00,$00,$00,$00  ; DMC

irq_handler:
    RTI

.segment "VECTORS"
    .word nmi_handler, reset, irq_handler

.segment "CHARS"
    .res 8192, $00
