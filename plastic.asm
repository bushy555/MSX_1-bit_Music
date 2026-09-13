; Plastic Galaxy.
; HUBY engine


	output "plastic.rom"		; Include this for SJASM assembler, exclude using PASMO assembler.

 	org 	$4000
 	defb 	"AB"
 	defw 	start
 	defb 	00,00,00,00,00,00

start:


; *****************************************************************************
; * Huby beeper music engine by Shiru (shiru@mail.ru) 04'11
; * updated 99b version 11'13
; * By Shiru
; *
; * Tempo mod by Chris Cowley
; *
; * Produced by Beepola v1.08.01
; ******************************************************************************



begin: 	call 	$006C			; CLS
	LD 	HL, message1
	call	display

	di        
	LD    	HL, MUSICDATA1
       	CALL  	HUBY_PLAY
        RET


display:LD 	A, (HL)
	call 	$00A2			; Print char.
	inc 	HL
	ld 	a, 0
	cp 	(HL)
	JR 	NZ, display
	ret


OP_INCL:        EQU   $2C

HUBY_PLAY:      LD    C,(HL)              ; Read the tempo word
                INC   HL
                LD    B,(HL)
                INC   HL
                LD    E,(HL)              ; Offset to pattern data is 
                INC   HL                  ; kept in DE always. 
                LD    D,(HL)              ; And HL = current position in song layout.

READPOS:        INC   HL
                LD    A,(HL)              ; Read the pattern number for channel 1
                INC   HL
                OR    A
                RET   Z                   ; Zero signifies the end of the song

; This code is for handling Tempo changes in the middle of a song.
; As the song data specified in Beepola (see MUSICDATA below) doesn't
; have any tempo changes, this code has been commented out to save 9
; bytes. Uncomment it if you want to use this routine to play tunes
; that contain mid-song tempo changes...

                CP    $FF                 ; $FF signifies SET TEMPO
                JR    NZ,NOT_TEMPO
                LD    C,(HL)
                INC   HL
                LD    B,(HL)
                JR    READPOS

NOT_TEMPO:      PUSH  HL                  ; Store the layout pointer
                PUSH  DE                  ; Store the pattern offset pointer
                PUSH  BC                  ; Store current tempo
                LD    L,(HL)              ; Read the pattern number for channel 2
                LD    B,2                 ; DJNZ through following code twice (1x for each channel)
CALC_ADR:       LD    H,0                 ; Multiply pattern number by 8...
                ADD   HL,HL               ; x2
                ADD   HL,HL               ; x4
                ADD   HL,HL               ; x8
                ADD   HL,DE               ; Add the offset to the pattern data
                PUSH  HL                  ; Store the address of pattern data
                LD    L,A
                DJNZ  CALC_ADR            ; Do the same thing for channel 2
                EXX
                POP   HL
                POP   DE

                LD    B,8                 ; Fixed pattern length = 8 rows
READ_ROW:       LD    A,(DE)              ; Read note for channel 1
                INC   DE                  ; inc channel 1 row pointer
                EXX
                LD    H,A
                LD    D,A
                EXX
                LD    A,(HL)              ; Read note for channel 2
                INC   HL                  ; inc channel 2 row pointer
                EXX
                LD    L,A
                LD    E,A
                CP    OP_INCL             ; If channel 1 note == $2C then play drum
                JR    Z,SET_DRUMSLIDE
                XOR   A
SET_DRUMSLIDE:  LD    (SND_SLIDE),A
                POP   BC                  ; Retrieve tempo
                PUSH  BC
                DI

SOUND_LOOP:     XOR   A
                DEC   E
                JR    NZ,SND_LOOP1
                LD    E,L
                SUB   L
SND_SLIDE:      NOP                       ; This is set to INC L for the drum sound
SND_LOOP1:      DEC   D
                JR    NZ,SND_LOOP2
                LD    D,H
                SUB   H
SND_LOOP2:      SBC   A,A

	out	($AA), A

READKEYB:
;       	IN    A,($FE)
;                CPL
;                AND   $1F
;                JR    NZ,SND_LOOP3

                DEC   BC
                LD    A,B
                OR    C
                JR    NZ,SOUND_LOOP       ; 113/123 Ts

SND_LOOP3:     ; LD    HL,$1A19            ; Set HL' for returning to BASIC
                EXX   
                EI
                JR    NZ,PATTERN_END
                DJNZ  READ_ROW
PATTERN_END:    POP   BC
                POP   DE
                POP   HL
                JR    Z,READPOS           ; No key pressed, goto next pattern
                RET                       ; Otherwise return


; ************************************************************************
; * Song data...
; ************************************************************************
BORDER_CLR:          EQU $0
message1:	DEFB	'Plastic Galaxy.',00

	align 	256



; *** DATA ***
MUSICDATA1:
MUSICDATA:
                DEFW  $10D2               ; Initial tempo
                DEFW  PATTDATA - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $09
                DEFB  $06
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $13
                DEFB  $0C
                DEFB  $14
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $15
                DEFB  $12
                DEFB  $16
                DEFB  $17
                DEFB  $18
                DEFB  $19
                DEFB  $1A
                DEFB  $1B
                DEFB  $1C
                DEFB  $1D
                DEFB  $1E
                DEFB  $1F
                DEFB  $02
                DEFB  $20
                DEFB  $04
                DEFB  $21
                DEFB  $06
                DEFB  $22
                DEFB  $23
                DEFB  $24
                DEFB  $02
                DEFB  $20
                DEFB  $04
                DEFB  $25
                DEFB  $06
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $13
                DEFB  $0C
                DEFB  $14
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $15
                DEFB  $12
                DEFB  $16
                DEFB  $17
                DEFB  $18
                DEFB  $19
                DEFB  $1A
                DEFB  $1B
                DEFB  $1C
                DEFB  $1D
                DEFB  $1E
                DEFB  $1F
                DEFB  $02
                DEFB  $20
                DEFB  $04
                DEFB  $21
                DEFB  $06
                DEFB  $22
                DEFB  $23
                DEFB  $1F
                DEFB  $02
                DEFB  $20
                DEFB  $04
                DEFB  $25
                DEFB  $06
                DEFB  $26
                DEFB  $27
                DEFB  $28
                DEFB  $29
                DEFB  $2A
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2F
                DEFB  $2C
                DEFB  $29
                DEFB  $30
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $34
                DEFB  $35
                DEFB  $36
                DEFB  $37
                DEFB  $38
                DEFB  $39
                DEFB  $3A
                DEFB  $33
                DEFB  $3B
                DEFB  $35
                DEFB  $3C
                DEFB  $37
                DEFB  $3D
                DEFB  $39
                DEFB  $3E
                DEFB  $3F
                DEFB  $3E
                DEFB  $40
                DEFB  $41
                DEFB  $42
                DEFB  $43
                DEFB  $44
                DEFB  $45
                DEFB  $46
                DEFB  $47
                DEFB  $1A
                DEFB  $1A
                DEFB  $1A
                DEFB  $1A
                DEFB  $1A
                DEFB  $1A
                DEFB  $00                 ; End of song

PATTDATA:
                DEFB  $51, $40, $36, $2B, $24, $40, $36, $2B
                DEFB  $A1, $36, $2B, $20, $1B, $36, $2B, $20
                DEFB  $66, $44, $36, $28, $22, $44, $36, $28
                DEFB  $33, $51, $44, $36, $28, $51, $44, $36
                DEFB  $5B, $24, $1E, $18, $14, $24, $1E, $18
                DEFB  $B4, $30, $24, $1E, $18, $30, $24, $1E
                DEFB  $79, $33, $28, $22, $1B, $33, $28, $22
                DEFB  $3D, $28, $22, $1B, $14, $28, $22, $1B
                DEFB  $5B, $24, $1E, $18, $14, $24, $1E, $2C
                DEFB  $66, $2C, $2C, $6C, $24, $2C, $B4, $00
                DEFB  $33, $22, $17, $36, $1E, $12, $24, $00
                DEFB  $2C, $40, $A1, $36, $28, $1E, $A1, $1B
                DEFB  $20, $00, $00, $51, $20, $24, $00, $24
                DEFB  $2C, $2C, $66, $2D, $66, $33, $00, $66
                DEFB  $22, $00, $33, $24, $22, $28, $00, $33
                DEFB  $2C, $5B, $B4, $3D, $1E, $17, $00, $B4
                DEFB  $24, $28, $24, $00, $24, $1E, $00, $24
                DEFB  $2C, $2C, $79, $30, $28, $2C, $1E, $18
                DEFB  $1B, $00, $1B, $1E, $00, $24, $00, $1E
                DEFB  $20, $00, $00, $51, $20, $1E, $24, $00
                DEFB  $24, $00, $24, $00, $24, $28, $2D, $28
                DEFB  $00, $00, $30, $51, $00, $00, $60, $00
                DEFB  $2C, $2D, $28, $1B, $00, $2D, $28, $1B
                DEFB  $66, $00, $00, $00, $00, $00, $00, $00
                DEFB  $00, $2D, $28, $1B, $00, $2D, $28, $1E
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00
                DEFB  $48, $2D, $28, $1B, $3D, $2D, $28, $1B
                DEFB  $B4, $00, $00, $00, $00, $00, $00, $00
                DEFB  $48, $2D, $28, $2C, $3D, $2D, $28, $12
                DEFB  $00, $00, $00, $00, $5B, $B4, $5B, $17
                DEFB  $2C, $40, $36, $2B, $24, $40, $36, $2C
                DEFB  $2C, $44, $2C, $28, $22, $44, $36, $28
                DEFB  $2C, $24, $1E, $2C, $14, $24, $1E, $18
                DEFB  $2C, $33, $2C, $22, $1B, $33, $28, $22
                DEFB  $3D, $28, $22, $1B, $14, $28, $22, $28
                DEFB  $2C, $40, $36, $2B, $24, $40, $36, $2B
                DEFB  $2C, $24, $1E, $2C, $14, $24, $1E, $2C
                DEFB  $79, $3D, $2C, $2C, $88, $44, $44, $88
                DEFB  $30, $51, $60, $28, $28, $00, $00, $00
                DEFB  $B4, $00, $00, $00, $00, $00, $2C, $00
                DEFB  $26, $00, $00, $00, $00, $00, $00, $00
                DEFB  $00, $A1, $97, $79, $51, $4C, $2C, $2D
                DEFB  $00, $00, $00, $A1, $97, $79, $51, $4C
                DEFB  $2C, $00, $00, $00, $00, $00, $2C, $00
                DEFB  $33, $00, $00, $00, $00, $00, $00, $00
                DEFB  $88, $79, $51, $00, $00, $00, $00, $00
                DEFB  $00, $00, $88, $79, $51, $00, $00, $00
                DEFB  $00, $2C, $97, $79, $51, $4C, $3D, $2D
                DEFB  $44, $3D, $33, $00, $00, $00, $00, $00
                DEFB  $00, $00, $44, $3D, $33, $00, $00, $00
                DEFB  $2C, $00, $26, $1E, $72, $00, $26, $1E
                DEFB  $2D, $00, $00, $00, $00, $3D, $33, $2D
                DEFB  $2C, $4C, $66, $51, $66, $00, $72, $00
                DEFB  $26, $3D, $28, $3D, $2D, $3D, $33, $2D
                DEFB  $2C, $00, $3D, $26, $5B, $00, $3D, $26
                DEFB  $00, $00, $00, $00, $00, $3D, $33, $2D
                DEFB  $2C, $00, $3D, $26, $51, $00, $3D, $2C
                DEFB  $26, $3D, $22, $3D, $26, $3D, $28, $2D
                DEFB  $2D, $00, $00, $00, $00, $2D, $26, $22
                DEFB  $1E, $2D, $17, $2D, $19, $2D, $1C, $1E
                DEFB  $00, $00, $00, $00, $00, $2D, $26, $22
                DEFB  $1E, $2D, $00, $2D, $00, $2D, $26, $22
                DEFB  $72, $2C, $1E, $2C, $13, $2C, $00, $2C
                DEFB  $2C, $00, $22, $2C, $19, $2C, $22, $2C
                DEFB  $1E, $00, $14, $00, $13, $00, $14, $00
                DEFB  $72, $2C, $3D, $2C, $26, $2C, $2D, $2C
                DEFB  $3D, $5B, $00, $5B, $00, $5B, $4C, $44
                DEFB  $66, $00, $00, $00, $28, $00, $00, $00
                DEFB  $3D, $00, $00, $00, $22, $00, $00, $00
                DEFB  $2C, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2D, $00, $00, $00, $00, $00, $00, $00

	ds -$ & #3fff

end
