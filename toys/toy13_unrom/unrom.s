; unrom.s — UNROM (mapper 2) bank switching test ROM
;
; 4 x 16KB PRG banks (64KB total), CHR-RAM (no CHR-ROM)
; Banks 0-2: switchable at $8000-$BFFF
; Bank 3: fixed at $C000-$FFFF
;
; Each switchable bank has a unique marker byte at $8000:
;   Bank 0: $AA
;   Bank 1: $BB
;   Bank 2: $CC
;
; Test: Switch to each bank, read marker, store to RAM:
;   $10 ← bank 0 marker ($AA)
;   $11 ← bank 1 marker ($BB)
;   $12 ← bank 2 marker ($CC)

; --- iNES Header (Mapper 2, 4x16KB PRG, CHR-RAM) ---
.segment "HEADER"
    .byte "NES", $1A
    .byte $04              ; 4 x 16KB PRG-ROM = 64KB
    .byte $00              ; 0 = CHR-RAM
    .byte $20, $08         ; Mapper 2, horizontal mirroring, NES 2.0
    .byte $00              ; No submapper
    .byte $00              ; PRG ROM not 4 MiB+
    .byte $00              ; No PRG RAM
    .byte $07              ; 8192 bytes CHR RAM
    .byte $00              ; NTSC
    .byte $00              ; No special PPU

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
    current_bank: .res 1
    marker0:      .res 1   ; $11
    marker1:      .res 1   ; $12
    marker2:      .res 1   ; $13

.segment "RODATA"

; Bus conflict lookup table: banktable[N] = N
; Must be in the fixed bank so it's always accessible
banktable:
    .byte $00, $01, $02, $03

.segment "CODE"

MARKER_ADDR = $8000        ; All banks have marker at this address

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

    ; --- Switch to bank 0, read marker ---
    LDY #$00
    JSR bankswitch_y
    LDA MARKER_ADDR
    STA marker0

    ; --- Switch to bank 1, read marker ---
    LDY #$01
    JSR bankswitch_y
    LDA MARKER_ADDR
    STA marker1

    ; --- Switch to bank 2, read marker ---
    LDY #$02
    JSR bankswitch_y
    LDA MARKER_ADDR
    STA marker2

loop:
    JMP loop

; --- Bankswitch routine (bus conflict safe) ---
bankswitch_y:
    STY current_bank       ; Save for NMI restore
    TYA
    STA banktable, Y       ; Write to ROM address = bus conflict safe
    RTS

nmi_handler:
    ; Restore bank in case NMI interrupted during bank switch
    LDY current_bank
    TYA
    STA banktable, Y
    RTI

irq_handler:
    RTI

.segment "VECTORS"
    .word nmi_handler, reset, irq_handler
