; mmc1.s — MMC1 (mapper 1) bank switching test ROM
;
; 4 x 16KB PRG banks (64KB total), CHR-RAM
; Uses 5-write serial protocol to configure mapper and switch banks.
;
; Control register ($8000-$9FFF): $0E = fixed $C000, 8KB CHR, vertical mirroring
; PRG bank register ($E000-$FFFF): bank number (0-2 switchable)
;
; Marker verification: same pattern as toy13_unrom
;   Bank 0: $AA at $8000 → RAM $11
;   Bank 1: $BB at $8000 → RAM $12
;   Bank 2: $CC at $8000 → RAM $13

; --- iNES Header (Mapper 1, 4x16KB PRG, CHR-RAM) ---
.segment "HEADER"
    .byte "NES", $1A
    .byte $04              ; 4 x 16KB PRG-ROM = 64KB
    .byte $00              ; 0 = CHR-RAM
    .byte $10, $00         ; Mapper 1 (low nibble of byte 7 = 0, high nibble byte 6 = 1)
    .byte $00, $00, $00, $00
    .byte $00, $00, $00, $00

; --- Bank 0 data ($8000-$BFFF when switched in) ---
.segment "BANK0DAT"
    .byte $AA              ; Marker at $8000

; --- Bank 1 data ---
.segment "BANK1DAT"
    .byte $BB              ; Marker at $8000

; --- Bank 2 data ---
.segment "BANK2DAT"
    .byte $CC              ; Marker at $8000

; --- Fixed bank (Bank 3, $C000-$FFFF) ---
.segment "ZEROPAGE"
    current_bank: .res 1   ; $10
    marker0:      .res 1   ; $11
    marker1:      .res 1   ; $12
    marker2:      .res 1   ; $13

.segment "CODE"

MARKER_ADDR = $8000

reset:
    SEI
    CLD
    LDX #$FF
    TXS

    ; Disable PPU
    LDA #$00
    STA $2000
    STA $2001
    BIT $2002

    ; Wait 2 vblanks
vblankwait1:
    BIT $2002
    BPL vblankwait1
vblankwait2:
    BIT $2002
    BPL vblankwait2

    ; --- Reset MMC1 shift register ---
    ; Writing with bit 7 set resets the mapper to known state
    LDA #$80
    STA $8000

    ; --- Configure control register ($8000-$9FFF) ---
    ; Value $0E = %01110:
    ;   bits 0-1 = 10: vertical mirroring
    ;   bits 2-3 = 11: fixed $C000, switch $8000
    ;   bit 4    = 0:  8KB CHR mode
    LDA #$0E
    JSR mmc1_write_control

    ; --- Switch to bank 0, read marker ---
    LDA #$00
    JSR mmc1_load_prg_bank
    LDA MARKER_ADDR
    STA marker0

    ; --- Switch to bank 1, read marker ---
    LDA #$01
    JSR mmc1_load_prg_bank
    LDA MARKER_ADDR
    STA marker1

    ; --- Switch to bank 2, read marker ---
    LDA #$02
    JSR mmc1_load_prg_bank
    LDA MARKER_ADDR
    STA marker2

loop:
    JMP loop

; --- MMC1 serial write: control register ($8000-$9FFF) ---
; Input: A = 5-bit value to write
mmc1_write_control:
    STA $8000
    LSR A
    STA $8000
    LSR A
    STA $8000
    LSR A
    STA $8000
    LSR A
    STA $8000
    RTS

; --- MMC1 serial write: PRG bank register ($E000-$FFFF) ---
; Input: A = bank number (0-15)
mmc1_load_prg_bank:
    STA current_bank       ; Save for NMI restore
    STA $E000
    LSR A
    STA $E000
    LSR A
    STA $E000
    LSR A
    STA $E000
    LSR A
    STA $E000
    RTS

nmi_handler:
    ; Reset mapper and restore bank on NMI exit
    LDA #$80
    STA $8000              ; Reset shift register
    LDA current_bank
    JSR mmc1_load_prg_bank
    RTI

irq_handler:
    RTI

.segment "VECTORS"
    .word nmi_handler, reset, irq_handler
