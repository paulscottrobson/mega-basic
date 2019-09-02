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
		lda 	_Test,x
		sta 	IFT_LineBuffer,x
		bne 	_ttCopy		
		lda 	#IFT_LineBuffer & $FF
		ldx 	#IFT_LineBuffer >> 8
		jsr 	TokeniseString
		nop
_Test:		.text 	'  1234 "abc" "xyzw" .407E-4 42 hello+m9',0
		