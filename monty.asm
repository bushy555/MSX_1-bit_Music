; Monty on the run.
; HUBY engine


	output "monty.rom"		; Include this for SJASM assembler, exclude using PASMO assembler.

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
message1:	DEFB	'Monty on the Run.',00

	align 	256


MUSICDATA:      DEFW  $04D4               ; Initial tempo
                DEFW  PATTDATA - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $05
                DEFB  $02
                DEFB  $06
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $05
                DEFB  $02
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $05
                DEFB  $02
                DEFB  $06
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $05
                DEFB  $02
                DEFB  $07
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $09
                DEFB  $02
                DEFB  $0A
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $09
                DEFB  $02
                DEFB  $07
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $09
                DEFB  $02
                DEFB  $0A
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $09
                DEFB  $02
                DEFB  $0B
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $0D
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $0B
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $0D
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $0E
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $11
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $0E
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $11
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $01
                DEFB  $12
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $05
                DEFB  $02
                DEFB  $06
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $05
                DEFB  $02
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $13
                DEFB  $05
                DEFB  $13
                DEFB  $06
                DEFB  $14
                DEFB  $03
                DEFB  $15
                DEFB  $04
                DEFB  $14
                DEFB  $05
                DEFB  $12
                DEFB  $07
                DEFB  $14
                DEFB  $08
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $09
                DEFB  $16
                DEFB  $0A
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $09
                DEFB  $02
                DEFB  $07
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $13
                DEFB  $09
                DEFB  $13
                DEFB  $0A
                DEFB  $14
                DEFB  $08
                DEFB  $15
                DEFB  $04
                DEFB  $14
                DEFB  $09
                DEFB  $12
                DEFB  $0B
                DEFB  $14
                DEFB  $0C
                DEFB  $12
                DEFB  $04
                DEFB  $17
                DEFB  $03
                DEFB  $16
                DEFB  $0D
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $0B
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $18
                DEFB  $03
                DEFB  $14
                DEFB  $0D
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $12
                DEFB  $03
                DEFB  $02
                DEFB  $0E
                DEFB  $12
                DEFB  $0F
                DEFB  $17
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $17
                DEFB  $11
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $0E
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $11
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $01
                DEFB  $19
                DEFB  $03
                DEFB  $19
                DEFB  $04
                DEFB  $19
                DEFB  $05
                DEFB  $19
                DEFB  $06
                DEFB  $19
                DEFB  $03
                DEFB  $19
                DEFB  $04
                DEFB  $19
                DEFB  $05
                DEFB  $19
                DEFB  $01
                DEFB  $19
                DEFB  $03
                DEFB  $19
                DEFB  $04
                DEFB  $1A
                DEFB  $05
                DEFB  $1A
                DEFB  $06
                DEFB  $1B
                DEFB  $03
                DEFB  $1C
                DEFB  $04
                DEFB  $1B
                DEFB  $05
                DEFB  $19
                DEFB  $07
                DEFB  $1B
                DEFB  $08
                DEFB  $19
                DEFB  $04
                DEFB  $19
                DEFB  $09
                DEFB  $1D
                DEFB  $0A
                DEFB  $1D
                DEFB  $08
                DEFB  $1D
                DEFB  $04
                DEFB  $1D
                DEFB  $09
                DEFB  $1D
                DEFB  $07
                DEFB  $1D
                DEFB  $08
                DEFB  $1D
                DEFB  $04
                DEFB  $1A
                DEFB  $09
                DEFB  $1A
                DEFB  $0A
                DEFB  $1B
                DEFB  $08
                DEFB  $1C
                DEFB  $04
                DEFB  $1B
                DEFB  $09
                DEFB  $19
                DEFB  $0B
                DEFB  $1B
                DEFB  $0C
                DEFB  $19
                DEFB  $04
                DEFB  $1E
                DEFB  $03
                DEFB  $1D
                DEFB  $0D
                DEFB  $1D
                DEFB  $0C
                DEFB  $1D
                DEFB  $04
                DEFB  $1D
                DEFB  $03
                DEFB  $1D
                DEFB  $0B
                DEFB  $1D
                DEFB  $0C
                DEFB  $1D
                DEFB  $04
                DEFB  $1F
                DEFB  $03
                DEFB  $1B
                DEFB  $0D
                DEFB  $1B
                DEFB  $0C
                DEFB  $1B
                DEFB  $04
                DEFB  $19
                DEFB  $03
                DEFB  $19
                DEFB  $0E
                DEFB  $19
                DEFB  $0F
                DEFB  $1E
                DEFB  $04
                DEFB  $20
                DEFB  $10
                DEFB  $1E
                DEFB  $11
                DEFB  $1E
                DEFB  $0F
                DEFB  $1E
                DEFB  $04
                DEFB  $1E
                DEFB  $10
                DEFB  $1E
                DEFB  $0E
                DEFB  $1E
                DEFB  $0F
                DEFB  $1E
                DEFB  $04
                DEFB  $1E
                DEFB  $10
                DEFB  $1E
                DEFB  $11
                DEFB  $1E
                DEFB  $0F
                DEFB  $1E
                DEFB  $04
                DEFB  $1E
                DEFB  $10
                DEFB  $02
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $05
                DEFB  $15
                DEFB  $06
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $14
                DEFB  $05
                DEFB  $12
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $05
                DEFB  $12
                DEFB  $06
                DEFB  $02
                DEFB  $03
                DEFB  $13
                DEFB  $04
                DEFB  $17
                DEFB  $05
                DEFB  $16
                DEFB  $07
                DEFB  $02
                DEFB  $08
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $09
                DEFB  $15
                DEFB  $0A
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $14
                DEFB  $09
                DEFB  $12
                DEFB  $07
                DEFB  $02
                DEFB  $08
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $09
                DEFB  $12
                DEFB  $0A
                DEFB  $02
                DEFB  $08
                DEFB  $13
                DEFB  $04
                DEFB  $17
                DEFB  $09
                DEFB  $16
                DEFB  $0B
                DEFB  $02
                DEFB  $0C
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $03
                DEFB  $15
                DEFB  $0D
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $14
                DEFB  $03
                DEFB  $12
                DEFB  $0B
                DEFB  $02
                DEFB  $0C
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $03
                DEFB  $12
                DEFB  $0D
                DEFB  $02
                DEFB  $0C
                DEFB  $13
                DEFB  $04
                DEFB  $17
                DEFB  $03
                DEFB  $16
                DEFB  $0E
                DEFB  $02
                DEFB  $0F
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $15
                DEFB  $11
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $14
                DEFB  $10
                DEFB  $12
                DEFB  $0E
                DEFB  $02
                DEFB  $0F
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $12
                DEFB  $11
                DEFB  $02
                DEFB  $0F
                DEFB  $13
                DEFB  $04
                DEFB  $17
                DEFB  $10
                DEFB  $16
                DEFB  $01
                DEFB  $21
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $21
                DEFB  $05
                DEFB  $02
                DEFB  $06
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $15
                DEFB  $05
                DEFB  $02
                DEFB  $01
                DEFB  $21
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $21
                DEFB  $05
                DEFB  $02
                DEFB  $06
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $15
                DEFB  $05
                DEFB  $02
                DEFB  $07
                DEFB  $21
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $21
                DEFB  $09
                DEFB  $02
                DEFB  $0A
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $15
                DEFB  $09
                DEFB  $02
                DEFB  $07
                DEFB  $21
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $21
                DEFB  $09
                DEFB  $02
                DEFB  $0A
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $15
                DEFB  $09
                DEFB  $02
                DEFB  $0B
                DEFB  $21
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $21
                DEFB  $03
                DEFB  $02
                DEFB  $0D
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $15
                DEFB  $03
                DEFB  $02
                DEFB  $0B
                DEFB  $21
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $21
                DEFB  $03
                DEFB  $02
                DEFB  $0D
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $15
                DEFB  $03
                DEFB  $02
                DEFB  $0E
                DEFB  $15
                DEFB  $0F
                DEFB  $22
                DEFB  $04
                DEFB  $15
                DEFB  $10
                DEFB  $02
                DEFB  $11
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $14
                DEFB  $10
                DEFB  $02
                DEFB  $0E
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $11
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $00                 ; End of song

PATTDATA:
                DEFB  $2C, $66, $11, $66, $22, $66, $11, $00
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $66, $0C, $66, $19, $66, $0C, $00
                DEFB  $17, $00, $00, $00, $17, $00, $00, $00
                DEFB  $2C, $44, $0C, $44, $19, $44, $0C, $00
                DEFB  $2C, $66, $00, $66, $11, $66, $00, $00
                DEFB  $2C, $79, $11, $79, $22, $79, $11, $00
                DEFB  $2C, $79, $0C, $79, $19, $79, $0C, $00
                DEFB  $2C, $51, $0C, $51, $19, $51, $0C, $00
                DEFB  $2C, $79, $00, $79, $11, $79, $00, $00
                DEFB  $2C, $97, $11, $97, $22, $97, $11, $00
                DEFB  $2C, $97, $0C, $97, $19, $97, $0C, $00
                DEFB  $2C, $97, $00, $97, $11, $97, $00, $00
                DEFB  $2C, $88, $11, $88, $22, $88, $11, $00
                DEFB  $2C, $88, $0C, $88, $19, $88, $0C, $00
                DEFB  $2C, $5B, $0C, $5B, $19, $5B, $0C, $00
                DEFB  $2C, $88, $00, $88, $11, $88, $00, $00
                DEFB  $14, $00, $00, $00, $00, $00, $00, $00
                DEFB  $13, $00, $00, $00, $14, $00, $00, $00
                DEFB  $13, $00, $00, $00, $00, $00, $00, $00
                DEFB  $11, $00, $00, $00, $00, $00, $00, $00
                DEFB  $19, $00, $00, $00, $00, $00, $00, $00
                DEFB  $17, $00, $00, $00, $00, $00, $00, $00
                DEFB  $1E, $00, $00, $00, $00, $00, $00, $00
                DEFB  $19, $14, $19, $14, $19, $14, $19, $14
                DEFB  $17, $13, $17, $13, $19, $14, $19, $14
                DEFB  $17, $13, $17, $13, $17, $13, $17, $13
                DEFB  $14, $11, $14, $11, $14, $11, $14, $11
                DEFB  $1E, $19, $1E, $19, $1E, $19, $1E, $19
                DEFB  $1B, $17, $1B, $17, $1B, $17, $1B, $17
                DEFB  $26, $1E, $26, $1E, $26, $1E, $26, $1E
                DEFB  $1B, $17, $1B, $17, $00, $00, $00, $00
                DEFB  $0C, $00, $00, $00, $00, $00, $00, $00
                DEFB  $0F, $00, $00, $00, $00, $00, $00, $00


	ds -$ & #3fff

end
