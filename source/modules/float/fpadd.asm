; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fpadd.asm
;		Purpose :	Floating Point Add/Subtract
;		Date :		18th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;								Subtract X2 from X1 (floating point)
;	
; *******************************************************************************************

FPSubtract:
		pha
		lda 	XS2_Type,x 					; flip the sign of X2 and add
		eor 	#$80
		sta 	XS2_Type,x
		pla 								; --- and fall through ---

; *******************************************************************************************
;
;								Add X2 to X1 (floating point)
;	
; *******************************************************************************************

FPAdd:	
		pha
		lda 	XS_Type,x 					; if X1 is -ve, specialised code
		bne 	_FPA_NegativeLHS 
		jsr 	FPAdd_Worker 				; if +ve use standard worker unchanged.
		pla
		rts
;
;		-A +- B
;
_FPA_NegativeLHS:
		lda 	XS_Type,x 					; flip sign of X1 and X2
		eor 	#$80
		sta 	XS_Type,x
		lda 	XS2_Type,x 					; flip the sign of B and add
		eor 	#$80
		sta 	XS2_Type,x
		jsr 	FPAdd_Worker 				; do the add calculation.
		lda 	XS_Type,x 					; flip sign of X1 back
		eor 	#$80
		sta 	XS_Type,x
		pla
		rts

; *******************************************************************************************
;
;								Add B to A where A is positive.
;
; *******************************************************************************************

FPAdd_Worker:
		bit 	XS2_Type,x					; if X2 is zero (e.g. adding zero)
		bvs 	_FPAWExit 					; no change.
		bit 	XS_Type,x 					; if X1 is zero (e.g. 0 + X2)
		bvc 	_FPAWMakeSame 				; then return X2, else make same exponent
		jsr 	FPUCopyX2ToX1 				; copy X2 to X1
_FPAWExit:		
		jsr 	FPUNormalise 				; normalise the result.
		rts		 	
		;
		;		Shift exponent and mantissa until values are the same.
		;
_FPAWMakeSame:		
		lda 	XS_Exponent,x 				; check if exponents are the same.
		sec
		sbc	 	XS2_Exponent,x 				; using subtraction
		beq 	_FPAW_DoArithmetic 			; if they are, do the actual arithmetic part.

		phx 								; save X
		bcc 	_FPAWShiftA 				; if X1 < X2 then shift X1
		inx6 								; if X1 >= X2 then shift X2
_FPAWShiftA:
		inc 	XS_Exponent,x 				; so shift exponent up.
		#lsr32x XS_Mantissa 				; and shift mantissa right 1
		plx 								; restore original X
		bra 	_FPAWMakeSame 				; keep going till exponents are the same.
		;		
_FPAW_DoArithmetic:		
		bit 	XS2_Type,x 					; is it adding a negative to a positive
		bmi 	_FPAW_BNegative
		;
		;		Adding X2 to X1, both +ve
		;
		#add32x XS_Mantissa,XS2_Mantissa  	
		bcc 	_FPAWExit 					; no carry.
		inc 	XS_Exponent,x 				; so shift exponent up.
		sec
		#ror32x XS_Mantissa 				; and rotate carry and mantissa right.
		bra 	_FPAWExit
		;
		;		Adding B to A, B is -ve, A is +ve
		;
_FPAW_BNegative:
		#sub32x	XS_Mantissa,XS2_Mantissa 	; difference.
		bcs		_FPAWGoExit 				; no borrow, e.g. the result is positive.	
		jsr 	FPUNegateInteger			; negate the mantissa
		lda 	XS_Type,x 					; flip result sign
		eor 	#$80
		sta 	XS_Type,x
_FPAWGoExit:		
		jmp 	_FPAWExit
