; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		abs.asm
;		Purpose :	Abs( unary function
;		Date :		22nd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Abs: 	;; abs(
		jsr 	EvaluateNumberX 			; get value
		jsr 	CheckNextRParen 			; check right bracket.
		lda 	XS_Type,x 					; get type
		and 	#15 						; if type bits zero, it's float.
		beq 	_UAMinusFloat
		lda 	XS_Mantissa+3,x 			; check MSB of upper byte to see if negative
		bpl 	_UAExit
		jmp 	IntegerNegateAlways 		; if so negate it.
		
;
;		|float| just clears the sign bit.
;
_UAMinusFloat:
		lda 	XS_Type,x 					; clear the sign bit.	
		and		#$7F
		sta 	XS_Type,x
_UAExit:		
		rts
