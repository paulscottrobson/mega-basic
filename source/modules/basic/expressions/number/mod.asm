; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		mod.asm
;		Purpose :	mod( unary function
;		Date :		22nd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Mod:	;; 	mod(
		jsr 	_UMParameter 				; first parameter
		jsr 	CheckNextComma
		phx 								; second parameter
		inx6 		
		jsr 	_UMParameter
		plx
		jsr 	CheckNextRParen
		jsr 	DivInteger32 				; divide
		lda 	zLTemp1+0 					; modulus is in zLTemp, copy it.
		sta 	XS_Mantissa+0,x
		lda 	zLTemp1+1
		sta 	XS_Mantissa+1,x
		lda 	zLTemp1+2
		sta 	XS_Mantissa+2,x
		lda 	zLTemp1+3
		sta 	XS_Mantissa+3,x
		rts

_UMParameter:
		jsr 	EvaluateNumberX 			; get value
		jsr 	FPUToInteger 				; make integer.
		lda 	XS_Mantissa+3,x 			; absolute value
		bpl 	_UMNotSigned
		jsr 	IntegerNegateAlways
_UMNotSigned:
		rts		