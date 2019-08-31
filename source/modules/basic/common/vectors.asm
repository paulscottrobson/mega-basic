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

CharPrint:
		jmp 	IFT_PrintCharacter

CharGet:
		jmp 	IF_GetKey

CheckBreak:
		jmp 	IF_CheckBreak

CharGetPosition:
		lda 	IFT_XCursor
		rts
