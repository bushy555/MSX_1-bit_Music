; Root Beer Rag
; HUBY engine


	output "rootbeer.rom"		; Include this for SJASM assembler, exclude using PASMO assembler.

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
message1:	DEFB	'Root Beer Rag.',00


	align 256

; *** DATA ***
MUSICDATA1:
MUSICDATA:
                DEFW  $073A               ; Initial tempo
                DEFW  PATTDATA - 8        ; Ptr to start of pattern data - 8
                DEFB  $FF                 ; Tempo change
                DEFW  $0C06               ; New tempo value
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
                DEFB  $09
                DEFB  $04
                DEFB  $0A
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $13
                DEFB  $14
                DEFB  $15
                DEFB  $16
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $17
                DEFB  $18
                DEFB  $19
                DEFB  $1A
                DEFB  $1B
                DEFB  $1C
                DEFB  $1D
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
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
                DEFB  $09
                DEFB  $04
                DEFB  $0A
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $13
                DEFB  $14
                DEFB  $15
                DEFB  $16
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $17
                DEFB  $18
                DEFB  $19
                DEFB  $1A
                DEFB  $1B
                DEFB  $1C
                DEFB  $1D
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $22
                DEFB  $23
                DEFB  $24
                DEFB  $25
                DEFB  $26
                DEFB  $27
                DEFB  $28
                DEFB  $21
                DEFB  $22
                DEFB  $23
                DEFB  $24
                DEFB  $29
                DEFB  $2A
                DEFB  $2B
                DEFB  $20
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2F
                DEFB  $30
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
                DEFB  $20
                DEFB  $00                 ; End of song

PATTDATA:
                DEFB  $88, $00, $00, $00, $00, $00, $00, $00
                DEFB  $22, $44, $2D, $22, $44, $2D, $22, $44
                DEFB  $48, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2D, $22, $44, $2D, $22, $44, $2D, $22
                DEFB  $51, $00, $00, $00, $00, $00, $00, $00
                DEFB  $22, $44, $33, $22, $44, $33, $22, $44
                DEFB  $66, $00, $00, $00, $00, $00, $00, $00
                DEFB  $33, $22, $44, $33, $22, $44, $33, $22
                DEFB  $90, $00, $00, $00, $00, $00, $00, $00
                DEFB  $A1, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $00, $3D, $00, $3D, $36, $2C, $2C
                DEFB  $00, $44, $2D, $44, $2D, $2D, $00, $44
                DEFB  $2C, $00, $3D, $00, $3D, $36, $44, $40
                DEFB  $2D, $44, $2D, $44, $2D, $2D, $00, $00
                DEFB  $2C, $00, $26, $00, $26, $00, $2C, $2C
                DEFB  $33, $00, $1E, $00, $1E, $00, $1E, $00
                DEFB  $2C, $00, $00, $00, $44, $00, $00, $00
                DEFB  $22, $2D, $33, $00, $33, $00, $00, $00
                DEFB  $2C, $00, $3D, $00, $3D, $00, $2C, $2C
                DEFB  $33, $00, $33, $00, $33, $00, $33, $00
                DEFB  $2C, $00, $00, $00, $3D, $00, $00, $00
                DEFB  $3D, $51, $5B, $00, $5B, $00, $00, $00
                DEFB  $2C, $00, $00, $00, $22, $00, $00, $00
                DEFB  $22, $2D, $33, $00, $33, $00, $00, $28
                DEFB  $2C, $00, $00, $00, $60, $00, $00, $00
                DEFB  $00, $2B, $28, $24, $1E, $22, $24, $28
                DEFB  $2C, $00, $00, $00, $51, $00, $00, $00
                DEFB  $2D, $30, $2D, $2B, $28, $2D, $33, $36
                DEFB  $2C, $00, $00, $00, $5B, $00, $00, $00
                DEFB  $3D, $40, $3D, $36, $2D, $33, $36, $3D
                DEFB  $2C, $00, $5B, $00, $88, $00, $00, $00
                DEFB  $44, $00, $00, $00, $00, $00, $00, $00
                DEFB  $5B, $00, $51, $00, $4C, $00, $48, $00
                DEFB  $48, $00, $44, $00, $40, $00, $3D, $00
                DEFB  $44, $00, $48, $00, $5B, $00, $6C, $00
                DEFB  $36, $00, $3D, $00, $48, $00, $5B, $00
                DEFB  $44, $00, $3D, $00, $39, $00, $36, $00
                DEFB  $36, $00, $33, $00, $30, $00, $2D, $00
                DEFB  $33, $00, $36, $00, $33, $00, $36, $00
                DEFB  $28, $00, $2D, $00, $28, $00, $2D, $00
                DEFB  $66, $00, $6C, $00, $00, $00, $66, $00
                DEFB  $51, $00, $5B, $00, $00, $00, $44, $00
                DEFB  $6C, $00, $00, $00, $00, $00, $00, $00
                DEFB  $B4, $5B, $A1, $51, $97, $4C, $90, $48
                DEFB  $00, $48, $00, $44, $00, $40, $00, $3D
                DEFB  $88, $44, $90, $48, $B4, $5B, $6C, $6C
                DEFB  $00, $36, $00, $3D, $00, $48, $00, $5B
                DEFB  $88, $44, $79, $3D, $72, $39, $6C, $36
                DEFB  $00, $36, $00, $33, $00, $30, $00, $2D
                DEFB  $66, $33, $6C, $36, $66, $33, $6C, $36
                DEFB  $00, $28, $00, $2D, $00, $28, $00, $2D
                DEFB  $66, $00, $00, $00, $60, $00, $00, $00
                DEFB  $00, $28, $44, $51, $28, $30, $44, $51
                DEFB  $5B, $00, $00, $40, $51, $40, $00, $00
                DEFB  $2D, $44, $5B, $28, $00, $28, $00, $00
                DEFB  $79, $00, $00, $00, $5B, $00, $00, $00
                DEFB  $36, $44, $36, $44, $36, $44, $3D, $00
                DEFB  $88, $00, $5B, $00, $88, $00, $00, $00

	ds -$ & #3fff

end
