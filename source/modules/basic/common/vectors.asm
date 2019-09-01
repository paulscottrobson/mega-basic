; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		vectors.asm
;		Purpose :	Vectored I/O
;		Date :		29th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

VIOCharPrint:
		jmp 	IFT_PrintCharacter

VIOCharGet:
		jsr 	IF_GetKey
		cmp 	#0
		beq 	_VCG0
		sec
		rts
_VCG0:	clc
		rts

VIOCheckBreak:
		jmp 	IF_CheckBreak

VIOCharGetPosition:
		lda 	IFT_XCursor
		rts

VIOReadLine:
		jmp 	IFT_ReadLine