; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fpcompare.asm
;		Purpose :	Compare 2 FP Numbers
;		Date :		18th August 2019
;		Review : 	4th September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;					Compare X1-X2 - returns -1,0,1 depending on difference.
;
;	This is an approximate comparison, so values where |a-b| < c will still return zero
;	because of rounding errors. c is related to the scale of a and b, not a fixed
; 	constant.
;
; *******************************************************************************************

FPCompare:
		jsr 	FPFastCompare 				; fast compare try first
		bcs 	_FPCExit 					; that worked.
		;
		;		Can't do it easily - so we have to subtract.
		;		
		lda 	XS_Exponent,x 				; save the exponents on the stack
		pha
		lda 	XS2_Exponent,x
		pha
		;
		jsr 	FPSubtract 					; calculate X1-X2
		bit 	XS_Type,x 					; is the result zero ? (e.g. zero flag set)
		bvs 	_FPCPullZero 				; if so, then return zero throwing saved exponents
		;
		pla
		sta 	ExpTemp						; save first exponent in temporary reg.
		pla 	
		sec
		sbc 	ExpTemp 					; calculate AX-BX
		bvs 	_FPCNotEqual				; overflow, can't be equal.
		;
		inc 	a 							; map -1,0,1 to 0,1,2
		cmp 	#3 							; if >= 3 e.g. abs difference > 1
		bcs 	_FPCNotEqual  				; exponents can't be more than 2 out.
		;
		;
		sec
		lda 	ExpTemp 					; get one of the exponents back.
		sbc 	#18 						; allow for 2^18 error, relatively.
		bcs 	_FPCNotRange 				; keep in range.
		lda 	#1 							
_FPCNotRange:		
		sec
		sbc 	XS_Exponent,x  				; if exponent of difference greater than this
		bcs 	_FPCZero 					; then error is nearly zero, so we let it go.
		;
_FPCNotEqual:
		lda 	XS_Type,x					; so this needs to be $FF (-ve) $01 (+ve)
		and 	#$80 						; $80 if -ve, $00 if +ve
		beq 	_FPCNE2
		lda 	#$FE 						; $FE if -ve, $00 if +ve
_FPCNE2:inc 	a 							; $FF if -ve, $01 if +ve
		bra 	_FPCExit 
		;
_FPCPullZero:
		pla 								; throw saved exponents
		pla
_FPCZero:		
		lda 	#0 							; and return zero
_FPCExit:		
		rts

; *******************************************************************************************
;
;									Special case tests
;
; *******************************************************************************************

FPFastCompare:
		bit 	XS_Type,x 					; n1 is zero.
		bvs 	_FPFLeftZero 				; return invert sign of n2 (0-n2)
		bit 	XS2_Type,x 					; n2 is zero ?
		lda 	XS_Type,x 					; if so, return sign bit of n1 (n1-0)
		bvs 	_FPFSignBit
		;
		;		Neither is zero. Now check the signs.
		;
		eor 	XS2_Type,x 					; eor 2 type bits. now know both non-zero
		asl 	a 							; put in CS if different.
		lda 	XS_Type,x 					; if signs different return sign of first
		bcs 	_FPFSignBit
		;
		;		Same sign. So check the exponents
		;
		sec 								; same sign and not-zero. compare exponents
		lda 	XS_Exponent,x 				; compare exponents. if the same, then fail.
		sbc 	XS2_Exponent,x 				; e.g. we have to do it via subtraction.
		beq 	_FPNoFastCompare
		;
		ror 	a 							; put carry into bit 7.
		bit 	XS_Type,X 					; if it is +x then flip it.		
		bmi		_FPFCNotMinus
		eor 	#$80
_FPFCNotMinus:
		bra		_FPFSignBit
		;
_FPNoFastCompare:		
		clc
		rts
_FPFZero:
		lda 	#0
_FPFExitSet:		
		sec 	
		rts

_FPFLeftZero:								; 0 compare n returns -sgn(n)
		bit 	XS2_Type,x 					; if right is zero, return zero.
		bvs 	_FPFZero
		lda 	XS2_Type,x 					; flip sign bit
		eor 	#$80						; return that as a sign.
		;
_FPFSignBit:								; return 1 if A.7=0, else -1
		asl 	a
		lda 	#1
		bcc		_FPFExitSet
		lda 	#$FF
		sec
		rts
