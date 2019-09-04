; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fpmultiply.asm
;		Purpose :	Floating Point Multiply
;		Date :		18th August 2019
;		Review : 	4th September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;								Multiply X1 by X2 (floating point)
;	
; *******************************************************************************************

FPMultiply:
		pha
		phy
		bit 	XS_Type,x 					; if X1 = 0, return X1 e.g. zero.
		bvs 	_FPM_Exit
		bit		XS2_Type,x 					; if X2 = 0, return X2 unchanged, e.g. zero :)
		bvc 	_FPM_CalcExponent
		jsr 	FPUCopyX2ToX1
_FPM_Exit:
		ply
		pla
		rts		
		;
		;		We're not multiplying by zero.
		;
_FPM_CalcExponent:		
		clc
		jsr 	FPCalculateExponent 		; calc exponent of product. (also used by divide)
		sta 	XS_Exponent,x 				; save the result.
		;
		lda 	#0
		sta 	zLTemp1+0 					; clear the long temp which is upper word of
		sta 	zLTemp1+1 					; long product. lower word is mantissa-A
		sta 	zLTemp1+2 					; multiplicand is mantissa-B
		sta 	zLTemp1+3
		;
		ldy 	#32							; X is loop counter, do it 32 times.
_FPM_Loop:
		lda 	XS_Mantissa,x				; check LSB of long product
		and 	#1
		clc 								; clear carry for the long rotate.
		beq 	_FPM_NoAddition

		clc 								; add X2 mantissa to the MSB of the long product.
		lda 	zLTemp1+0
		adc 	XS2_Mantissa+0,x
		sta 	zLTemp1+0
		lda 	zLTemp1+1
		adc 	XS2_Mantissa+1,x
		sta 	zLTemp1+1
		lda 	zLTemp1+2
		adc 	XS2_Mantissa+2,x
		sta 	zLTemp1+2
		lda 	zLTemp1+3
		adc 	XS2_Mantissa+3,x
		sta 	zLTemp1+3

_FPM_NoAddition:
		#ror32 	zLTemp1 					; rotate the long product right.
		#ror32x XS_Mantissa,x				; standard rotate multiply algorithm here.

		dey
		bne 	_FPM_Loop 					; do this 32 times.

		;
		;		Copy ZLTemp to result,  fix the signs, normalise, used by Divide as well.
		;
FPM_CopySignNormalize:
		lda 	zLTemp1+0 					; copy the left product into Mantissa A.
		sta 	XS_Mantissa,x 				; which is the 32 x 32 product upper bits.
		lda 	zLTemp1+1
		sta 	XS_Mantissa+1,x
		lda 	zLTemp1+2
		sta 	XS_Mantissa+2,x
		lda 	zLTemp1+3
		sta 	XS_Mantissa+3,x

		lda 	XS_Type,x 					; sign is xor of signs
		eor 	XS2_Type,x
		sta 	XS_Type,x

		jsr 	FPUNormalise 				; normalise and exit.
		ply
		pla
		rts		

; *******************************************************************************************
;
;							Calculate overflow of exponent sums
;
; *******************************************************************************************

FPCalculateExponent:
		clc
		lda 	XS_Exponent,x 				; this is with $80 being 2^0.
		adc 	XS2_Exponent,x
		bcs 	_FPCECarry 					; carry out ?
		;
		bpl 	_FPCEExpZero 				; if 0-127 then the product < minimum float		
		and 	#$7F 						; this is the actual exponent.
		rts
_FPCEExpZero:
		lda 	#0
		rts		
		;
_FPCECarry:
		bmi 	_FPCEOverflow 				; overflow if say 255 + 129 (2^127+2^1)
		ora 	#$80 						; put in right range
		rts

_FPCEOverflow:
		jmp 	FP_Overflow		
