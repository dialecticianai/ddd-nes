; math.s — 6502 math routine test ROM
;
; Implements and tests:
;   1. General 8x8 unsigned multiply (A * Y → 16-bit result)
;   2. General 8-bit unsigned divide (A / X → quotient + remainder)
;
; Test cases stored in RAM:
;   $0300-$0307: multiply results (4 tests x 2 bytes: lo, hi)
;   $0310-$0317: divide results (4 tests x 2 bytes: quotient, remainder)

.segment "HEADER"
    .byte "NES", $1A
    .byte $01, $01, $00, $00
    .res 8, $00

.segment "ZEROPAGE"
    factor1:   .res 1     ; $10 — multiply temp (becomes low byte of result)
    factor2:   .res 1     ; $11 — multiplicand
    dividend:  .res 1     ; $12 — divide temp (becomes quotient)
    divisor:   .res 1     ; $13 — divisor
    frame_ctr: .res 1     ; $14

.segment "CODE"

reset:
    SEI
    CLD
    LDX #$FF
    TXS

    LDA #$00
    STA frame_ctr
    STA $2000
    STA $2001
    BIT $2002

vblankwait1:
    BIT $2002
    BPL vblankwait1
vblankwait2:
    BIT $2002
    BPL vblankwait2

    ; === Multiply tests ===

    ; Test 1: 7 * 6 = 42 (lo=42, hi=0)
    LDA #7
    LDY #6
    JSR multiply
    STA $0300              ; lo = 42
    STX $0301              ; hi = 0

    ; Test 2: 13 * 20 = 260 (lo=4, hi=1)
    LDA #13
    LDY #20
    JSR multiply
    STA $0302
    STX $0303

    ; Test 3: 255 * 255 = 65025 (lo=$01, hi=$FE)
    LDA #255
    LDY #255
    JSR multiply
    STA $0304
    STX $0305

    ; Test 4: 0 * 99 = 0
    LDA #0
    LDY #99
    JSR multiply
    STA $0306
    STX $0307

    ; === Divide tests ===

    ; Test 1: 42 / 7 = 6 remainder 0
    LDA #42
    LDX #7
    JSR divide
    STA $0310              ; quotient = 6
    STY $0311              ; remainder = 0

    ; Test 2: 100 / 3 = 33 remainder 1
    LDA #100
    LDX #3
    JSR divide
    STA $0312
    STY $0313

    ; Test 3: 255 / 1 = 255 remainder 0
    LDA #255
    LDX #1
    JSR divide
    STA $0314
    STY $0315

    ; Test 4: 5 / 10 = 0 remainder 5
    LDA #5
    LDX #10
    JSR divide
    STA $0316
    STY $0317

    ; Enable NMI
    LDA #%10000000
    STA $2000

loop:
    JMP loop

; === General 8x8 Unsigned Multiply ===
; Input: A = multiplicand, Y = multiplier
; Output: A = result low byte, X = result high byte
; Destroys: A, X, Y
; ~200 cycles worst case
multiply:
    STA factor1            ; factor1 = multiplicand (becomes low byte)
    STY factor2            ; factor2 = multiplier
    LDA #0                 ; A = accumulator (becomes high byte)
    LDX #8                 ; 8 bits to process
    LSR factor1            ; shift first bit of multiplicand into carry

@mul_loop:
    BCC @skip_add
    CLC
    ADC factor2            ; add multiplier to high accumulator
@skip_add:
    ROR A                  ; shift high byte right
    ROR factor1            ; shift into low byte (carries from high)
    DEX
    BNE @mul_loop

    TAX                    ; X = high byte
    LDA factor1            ; A = low byte
    RTS

; === General 8-bit Unsigned Divide ===
; Input: A = dividend, X = divisor
; Output: A = quotient, Y = remainder
; Destroys: A, X, Y
; ~200-250 cycles
divide:
    STA dividend           ; dividend (becomes quotient via ROL)
    STX divisor
    LDA #0                 ; A = remainder
    LDX #8                 ; 8 bits
    ASL dividend           ; pre-shift: MSB of dividend into carry

@div_loop:
    ROL A                  ; shift carry into remainder
    CMP divisor
    BCC @skip_sub
    SBC divisor            ; carry is set (CMP >= means no borrow)
@skip_sub:
    ROL dividend           ; shift quotient bit in (carry), next dividend bit out
    DEX
    BNE @div_loop

    TAY                    ; Y = remainder
    LDA dividend           ; A = quotient
    RTS

nmi_handler:
    INC frame_ctr
    RTI

irq_handler:
    RTI

.segment "VECTORS"
    .word nmi_handler, reset, irq_handler

.segment "CHARS"
    .res 8192, $00
