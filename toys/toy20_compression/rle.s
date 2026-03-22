; rle.s — RLE decompression test ROM
;
; Decompresses RLE-encoded data from RODATA to RAM buffer at $0300.
;
; RLE format:
;   Bit 7 set = run: length in bits 0-6, next byte = value to repeat
;   Bit 7 clear = literal byte, output directly
;   $80 = end marker (run of length 0)
;
; Test data: $85,$FF,$03,$42,$83,$AA,$07,$84,$55,$80
; Expected output (15 bytes): FF FF FF FF FF 03 42 AA AA AA 07 55 55 55 55
;
; RAM layout:
;   $10: output_count     $11: frame_counter
;   $12-$13: src_ptr      $14-$15: dst_ptr
;   $16: run_count (temp for run loop)

DEST_BASE = $0300

.segment "HEADER"
    .byte "NES", $1A
    .byte $01, $01, $00, $00
    .res 8, $00

.segment "ZEROPAGE"
    output_count: .res 1   ; $10
    frame_counter: .res 1  ; $11
    src_ptr:      .res 2   ; $12-$13
    dst_ptr:      .res 2   ; $14-$15
    run_count:    .res 1   ; $16

.segment "RODATA"

rle_data:
    .byte $85, $FF         ; run: 5x $FF
    .byte $03              ; literal $03
    .byte $42              ; literal $42
    .byte $83, $AA         ; run: 3x $AA
    .byte $07              ; literal $07
    .byte $84, $55         ; run: 4x $55
    .byte $80              ; end marker

.segment "CODE"

reset:
    SEI
    CLD
    LDX #$FF
    TXS

    LDA #$00
    STA output_count
    STA frame_counter
    STA $2000
    STA $2001
    BIT $2002

vblankwait1:
    BIT $2002
    BPL vblankwait1
vblankwait2:
    BIT $2002
    BPL vblankwait2

    ; Set up pointers
    LDA #<rle_data
    STA src_ptr
    LDA #>rle_data
    STA src_ptr+1

    LDA #<DEST_BASE
    STA dst_ptr
    LDA #>DEST_BASE
    STA dst_ptr+1

    ; Decompress
    JSR rle_decompress

    ; Enable NMI
    LDA #%10000000
    STA $2000

loop:
    JMP loop

; === RLE Decompression ===
; Uses Y=0 for indirect indexed addressing throughout.
; src_ptr and dst_ptr are incremented via helpers.
rle_decompress:
    LDY #0

@next:
    LDA (src_ptr), Y       ; read command byte
    BMI @run               ; bit 7 set = run or end

    ; --- Literal ---
    STA (dst_ptr), Y       ; Y=0, write literal to dest
    JSR inc_src
    JSR inc_dst
    INC output_count
    JMP @next

@run:
    AND #$7F               ; extract length
    BEQ @done              ; length 0 = end ($80)
    STA run_count          ; save run length

    ; Advance past command byte to run value
    JSR inc_src
    LDA (src_ptr), Y       ; read run value
    JSR inc_src            ; advance past value

    ; Write run_count copies
@run_loop:
    STA (dst_ptr), Y       ; Y=0
    JSR inc_dst
    INC output_count
    DEC run_count
    BNE @run_loop

    JMP @next

@done:
    RTS

; --- 16-bit pointer increment helpers ---
inc_src:
    INC src_ptr
    BNE :+
    INC src_ptr+1
:   RTS

inc_dst:
    INC dst_ptr
    BNE :+
    INC dst_ptr+1
:   RTS

nmi_handler:
    INC frame_counter
    RTI

irq_handler:
    RTI

.segment "VECTORS"
    .word nmi_handler, reset, irq_handler

.segment "CHARS"
    .res 8192, $00
