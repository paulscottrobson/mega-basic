; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		tokconst.asm
;		Purpose :	Tokenise Unsigned Integer Constant
;		Date :		2nd September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************
	
; *******************************************************************************************
;
;							Tokenise constant starting at (zGenPtr),y
;
; *******************************************************************************************

TokeniseConstant:
		phx 								; save X
		ldx 	#0
		jsr 	IntFromStringY 				; get the integer out.
		bcs 	_TCQ 						; should not happen.
		plx 								; restore X.
		lda 	#0 							; zero count of restores.
		sta 	zTemp1
_TCRotate:
		lda 	XS_Mantissa+0 				; check bits 6/7 of 0
		and 	#$C0
		ora 	XS_Mantissa+1	 			; and 1/2/3 all zero
		ora 	XS_Mantissa+2
		ora 	XS_Mantissa+3
		beq 	_TCDone						; if so, at the bottom.
		;
		lda 	XS_Mantissa+0 				; push lower 6 bits of 0
		and 	#$3F
		pha
		inc 	zTemp1 						; increment the pop count.
		;
		lda 	#6 							; shift right 6 times
_TCShiftRight:
		lsr 	XS_Mantissa+3
		ror 	XS_Mantissa+2
		ror 	XS_Mantissa+1
		ror 	XS_Mantissa+0
		dec 	a
		bne 	_TCShiftRight
		bra 	_TCRotate 					; and go round again.
		;
_TCDone:lda 	XS_Mantissa+0 				
		;
_TCWrite:		
		ora 	#$40						; write it out as inttoken
		sta 	TokeniseBuffer,x
		inx
		dec 	zTemp1 						; done all of them
		bmi 	_TCExit 					; no , more to pop
		pla
		bra 	_TCWrite 					; until everything's off.
_TCExit:
		rts						

_TCQ:	#Fatal	"TK"				

