# MSX_1-bit_Music

Experimental true 1-bit music on the MSX.

1-bit Beeper music can be created with the I/O port $00AA , or by the bIOS call $0135 (CHGSND)

Function:	calling this routine with setting 0 in the A register turns
		the bit of the sound port OFF; calling it with another value
		turns it ON.


This port/bios call is commonly known as the Key Click routine. By correct timing methods, this can be turned into 1-bit music.


A few details here in 1.3 and 1.4 : https://www.konamiman.com/msx/msx2th/th-5a.txt


A few changes are required to Speccy 1-bit music.
	out	($AA), A
.ROM files need to be a full 16384 bytes. Take note of the filler at the bottom of the source code.



Assemble with either SJASMplus or Pasmo to output to a .ROM binary file.
Use BLUEMSX emulator.
FilE --> insert cartridge slot 1 --> Insert.
Select .ROM file.   Will auto load, auto run and auto play.



	output "file.rom"	; use for SJASMplus.  Remark for PASMO.

 	org 	$4000
 	defb 	"AB"
 	defw 	start
 	defb 	00,00,00,00,00,00
start:
..
..

	ld   a,255
	out  ($aa),a		
	xor  a
        out  ($aa),a
..
..
	ds -$ & #3fff		; filler
END

