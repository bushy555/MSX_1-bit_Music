; Phazer.
; HUBY engine


	output "phazer.rom"		; Include this for SJASM assembler, exclude using PASMO assembler.

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
	LD    	HL, MUSICDATA
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
message1:	DEFB	'Phazer.',00

	align 	256


MUSICDATA:
                DEFW  $0E6C               ; Initial tempo
                DEFW  PATTDATA - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $02
                DEFB  $11
                DEFB  $04
                DEFB  $12
                DEFB  $06
                DEFB  $13
                DEFB  $08
                DEFB  $14
                DEFB  $0A
                DEFB  $15
                DEFB  $0C
                DEFB  $16
                DEFB  $0D
                DEFB  $17
                DEFB  $0F
                DEFB  $10
                DEFB  $18
                DEFB  $11
                DEFB  $19
                DEFB  $12
                DEFB  $1A
                DEFB  $1B
                DEFB  $1C
                DEFB  $14
                DEFB  $1D
                DEFB  $15
                DEFB  $1E
                DEFB  $16
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $10
                DEFB  $22
                DEFB  $11
                DEFB  $23
                DEFB  $12
                DEFB  $24
                DEFB  $1B
                DEFB  $25
                DEFB  $14
                DEFB  $26
                DEFB  $15
                DEFB  $27
                DEFB  $16
                DEFB  $28
                DEFB  $0F
                DEFB  $29
                DEFB  $2A
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2F
                DEFB  $30
                DEFB  $31
                DEFB  $2A
                DEFB  $32
                DEFB  $33
                DEFB  $34
                DEFB  $35
                DEFB  $36
                DEFB  $37
                DEFB  $38
                DEFB  $39
                DEFB  $3A
                DEFB  $3B
                DEFB  $3A
                DEFB  $3C
                DEFB  $3D
                DEFB  $3E
                DEFB  $3F
                DEFB  $39
                DEFB  $3A
                DEFB  $40
                DEFB  $41
                DEFB  $35
                DEFB  $42
                DEFB  $43
                DEFB  $44
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $02
                DEFB  $11
                DEFB  $04
                DEFB  $12
                DEFB  $06
                DEFB  $13
                DEFB  $08
                DEFB  $14
                DEFB  $0A
                DEFB  $15
                DEFB  $0C
                DEFB  $16
                DEFB  $0D
                DEFB  $17
                DEFB  $0F
                DEFB  $10
                DEFB  $18
                DEFB  $11
                DEFB  $19
                DEFB  $12
                DEFB  $1A
                DEFB  $1B
                DEFB  $1C
                DEFB  $14
                DEFB  $1D
                DEFB  $15
                DEFB  $1E
                DEFB  $16
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $10
                DEFB  $22
                DEFB  $11
                DEFB  $23
                DEFB  $12
                DEFB  $24
                DEFB  $1B
                DEFB  $25
                DEFB  $14
                DEFB  $26
                DEFB  $15
                DEFB  $27
                DEFB  $16
                DEFB  $28
                DEFB  $0F
                DEFB  $29
                DEFB  $2A
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2F
                DEFB  $30
                DEFB  $31
                DEFB  $2A
                DEFB  $32
                DEFB  $33
                DEFB  $34
                DEFB  $35
                DEFB  $36
                DEFB  $37
                DEFB  $38
                DEFB  $39
                DEFB  $3A
                DEFB  $3B
                DEFB  $3A
                DEFB  $3C
                DEFB  $3D
                DEFB  $3E
                DEFB  $3F
                DEFB  $39
                DEFB  $3A
                DEFB  $40
                DEFB  $41
                DEFB  $35
                DEFB  $42
                DEFB  $43
                DEFB  $44
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $FF                 ; Tempo change
                DEFW  $10D2               ; New tempo value
                DEFB  $0D
                DEFB  $0D
                DEFB  $45
                DEFB  $45
                DEFB  $FF                 ; Tempo change
                DEFW  $0C06               ; New tempo value
                DEFB  $46
                DEFB  $47
                DEFB  $1C
                DEFB  $47
                DEFB  $1C
                DEFB  $47
                DEFB  $1C
                DEFB  $47
                DEFB  $1C
                DEFB  $48
                DEFB  $1C
                DEFB  $1C
                DEFB  $1C
                DEFB  $1C
                DEFB  $1C
                DEFB  $1C
                DEFB  $FF                 ; Tempo change
                DEFW  $0E6C               ; New tempo value
                DEFB  $49
                DEFB  $1C
                DEFB  $1C
                DEFB  $1C
                DEFB  $00                 ; End of song

PATTDATA:
                DEFB  $2C, $79, $79, $79, $3D, $33, $79, $79
                DEFB  $F0, $F0, $F0, $F0, $79, $66, $F0, $F0
                DEFB  $79, $79, $3D, $33, $79, $79, $3D, $33
                DEFB  $F0, $F0, $79, $66, $F0, $F0, $79, $66
                DEFB  $88, $88, $88, $88, $44, $36, $88, $88
                DEFB  $00, $00, $00, $00, $88, $6C, $00, $00
                DEFB  $88, $88, $44, $36, $88, $88, $44, $36
                DEFB  $00, $00, $88, $6C, $00, $00, $88, $6C
                DEFB  $97, $97, $97, $97, $4C, $3D, $97, $97
                DEFB  $97, $97, $97, $97, $97, $79, $97, $97
                DEFB  $97, $97, $4C, $3D, $97, $97, $4C, $3D
                DEFB  $97, $97, $97, $79, $97, $97, $97, $79
                DEFB  $CB, $CB, $CB, $CB, $51, $44, $D7, $D7
                DEFB  $D7, $D7, $2C, $2C, $D7, $D7, $5B, $44
                DEFB  $D7, $D7, $5B, $44, $D7, $D7, $5B, $44
                DEFB  $2C, $79, $79, $79, $3D, $33, $2C, $79
                DEFB  $79, $79, $2C, $33, $79, $79, $3D, $33
                DEFB  $2C, $88, $88, $88, $44, $36, $2C, $88
                DEFB  $88, $88, $2C, $36, $88, $88, $44, $36
                DEFB  $2C, $97, $97, $97, $4C, $3D, $2C, $97
                DEFB  $97, $97, $2C, $3D, $97, $97, $4C, $3D
                DEFB  $2C, $CB, $CB, $CB, $2C, $44, $D7, $D7
                DEFB  $D7, $D7, $5B, $2C, $D7, $D7, $5B, $44
                DEFB  $1E, $1E, $00, $00, $00, $00, $28, $28
                DEFB  $1E, $1E, $1B, $1B, $19, $19, $14, $14
                DEFB  $00, $00, $1B, $1B, $1B, $00, $00, $00
                DEFB  $88, $88, $2C, $2C, $88, $88, $2C, $36
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00
                DEFB  $26, $26, $33, $33, $26, $26, $22, $22
                DEFB  $1E, $1E, $22, $22, $26, $26, $00, $00
                DEFB  $28, $28, $26, $26, $22, $22, $2D, $2D
                DEFB  $2C, $2C, $2C, $44, $2C, $D7, $2C, $2C
                DEFB  $00, $00, $17, $19, $1B, $22, $2D, $44
                DEFB  $3D, $36, $33, $2D, $36, $33, $2D, $28
                DEFB  $33, $2D, $28, $26, $2D, $28, $26, $22
                DEFB  $19, $1B, $22, $1B, $22, $2D, $22, $2D
                DEFB  $33, $2D, $33, $36, $33, $36, $44, $22
                DEFB  $13, $14, $17, $19, $14, $17, $19, $1B
                DEFB  $17, $19, $1B, $1E, $19, $1B, $1E, $22
                DEFB  $28, $22, $19, $22, $28, $22, $19, $22
                DEFB  $2D, $22, $1B, $22, $1B, $19, $17, $11
                DEFB  $2C, $4C, $3D, $4C, $2C, $4C, $33, $4C
                DEFB  $0F, $0F, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $4C, $33, $4C, $2C, $4C, $3D, $2C
                DEFB  $0F, $0F, $0D, $0D, $0C, $0C, $00, $00
                DEFB  $2C, $79, $3D, $79, $2C, $79, $33, $79
                DEFB  $00, $00, $0C, $0C, $14, $14, $00, $00
                DEFB  $2C, $88, $44, $88, $2C, $33, $36, $44
                DEFB  $00, $00, $0D, $0D, $11, $0F, $0D, $00
                DEFB  $0C, $0C, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $4C, $33, $4C, $2C, $2C, $2C, $2C
                DEFB  $0F, $0F, $13, $13, $19, $19, $0F, $0F
                DEFB  $2C, $51, $26, $51, $2C, $51, $2D, $51
                DEFB  $10, $10, $14, $14, $17, $17, $1B, $1B
                DEFB  $28, $2D, $33, $36, $3D, $40, $4C, $51
                DEFB  $14, $17, $19, $1B, $1E, $20, $26, $28
                DEFB  $2C, $4C, $3D, $4C, $36, $4C, $2C, $4C
                DEFB  $33, $26, $33, $3D, $33, $26, $33, $3D
                DEFB  $2D, $4C, $2C, $4C, $36, $4C, $3D, $4C
                DEFB  $2C, $79, $3D, $79, $36, $79, $2C, $79
                DEFB  $33, $28, $33, $3D, $33, $28, $33, $3D
                DEFB  $36, $88, $2C, $2C, $2D, $33, $2C, $44
                DEFB  $36, $2D, $36, $44, $5B, $44, $36, $2D
                DEFB  $26, $4C, $2C, $4C, $1E, $4C, $26, $4C
                DEFB  $33, $26, $33, $3D, $26, $1E, $26, $33
                DEFB  $36, $28, $36, $40, $36, $28, $36, $40
                DEFB  $2C, $2C, $2C, $36, $2C, $40, $2C, $2C
                DEFB  $51, $5B, $66, $6C, $79, $80, $97, $A1
                DEFB  $D7, $D7, $5B, $44, $5B, $44, $36, $2D
                DEFB  $F0, $00, $00, $00, $00, $00, $00, $00
                DEFB  $3D, $36, $33, $28, $1E, $28, $33, $36
                DEFB  $3D, $00, $00, $00, $00, $00, $00, $00
                DEFB  $00, $00, $2C, $00, $00, $00, $00, $00

	ds -$ & #3fff

end
