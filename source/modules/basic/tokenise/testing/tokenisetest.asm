; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		tokenisetest.asm
;		Purpose :	Test skeleton, tokenise ASCII string
;		Date :		2nd September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

TokeniseTest:		; tokenise IFT_LineBuffer -> TokenBuffer
					; and exit.
		#ResetStack
		ldx 	#255
_ttCopy:inx
		lda 	TokeniseTestIn,x
		sta 	IFT_LineBuffer,x
		bne 	_ttCopy		
		lda 	#IFT_LineBuffer & $FF
		ldx 	#IFT_LineBuffer >> 8
		jsr 	TokeniseString
		ldx 	#0
_ttCompare:
		lda 	TokeniseBuffer,x
		cmp 	TokeniseTestOut,x
_ttStop:bne 	_ttStop
		inx
		cpx 	#TokeniseTestOutEnd-TokeniseTestOut
		bne 	_ttCompare				
		jsr 	IFT_ClearScreen
		lda 	#42
		jsr 	IFT_PrintCharacter
		#exit
_ttWait:bra 	_ttWait

		.include "tokentest.src"