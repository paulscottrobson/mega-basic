; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fpdivide.asm
;		Purpose :	Divide B into A (floating point)
;		Date :		15th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

FPD_IsDivZero:								; here because of short branches
		jsr 		ERR_Handler
		.text 		"Division by zero",0

; *******************************************************************************************
;
;							Divide X2 into X1 (floating point)
;	
; *******************************************************************************************

FPDivide:
		pha
		phy
		bit 	XS2_Type,x 					; check if division by zero
		bvs 	FPD_IsDivZero 				; if X2 is zero, cause an error.
		;
		bit 	XS_Type,x 					; if 0/X (X is not zero) return 0
		beq 	_FPDCalculateExp
_FPD_Exit:
		ply
		pla		
		rts

		;
_FPDCalculateExp:
		lda 	XS2_Exponent,x 				; negate the 2nd exponent
		eor 	#$FF
		inc 	a
		sta 	XS2_Exponent,x
		jsr 	FPCalculateExponent 		; then we can use the multiply version.
		clc 	 							; add 1 to the resulting exponent
		adc 	#1
		bcs 	_FPD_Overflow 				; which can overflow.
		sta 	XS_Exponent,x
		;
		lda 	#0 							; clear result (kept in zLTemp1)
		sta 	zLTemp1+0
		sta 	zLTemp1+1
		sta 	zLTemp1+2
		sta 	zLTemp1+3
		;
		ldy 	#32 						; times round.
_FPD_Loop:
		sec 								; calculate X1-X2 stacking result because we might
		lda 	XS_Mantissa,x 				; not save it.
		sbc 	XS2_Mantissa,x		
		pha
		lda 	XS_Mantissa+1,x
		sbc 	XS2_Mantissa+1,x		
		pha
		lda 	XS_Mantissa+2,x
		sbc 	XS2_Mantissa+2,x		
		pha
		lda 	XS_Mantissa+3,x
		sbc 	XS2_Mantissa+3,x		
		;
		bcc		_FPD_NoSubtract 			; if CC couldn't subtract without borrowing.
		;
		sta 	XS_Mantissa+3,x 			; save results out to A
		pla
		sta 	XS_Mantissa+2,x
		pla
		sta 	XS_Mantissa+1,x
		pla
		sta 	XS_Mantissa+0,x
		;
		lda 	zLTemp1+3 					; set high bit of result
		ora 	#$80
		sta 	zLTemp1+3
		bra 	_FPD_Rotates
		;
_FPD_NoSubtract:
		pla 								; throw away unwanted results
		pla
		pla
		;
_FPD_Rotates:
		#lsr32x XS2_Mantissa 				; shift X2 right.

		asl 	zLTemp1 					; rotate result round left
		rol 	zLTemp1+1
		rol 	zLTemp1+2
		rol 	zLTemp1+3
		bcc 	_FPD_NoCarry
		inc 	zLTemp1 					; if rotated out, set LSB.
_FPD_NoCarry:						
		;
		dey 								; do 32 times
		bne 	_FPD_Loop
		;
		jmp 	FPM_CopySignNormalize 		; hijack multiply exit.

_FPD_Overflow:
		jmp 	FP_Overflow
		