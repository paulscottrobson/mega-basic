; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fputils.asm
;		Purpose :	Floating Point Utilities
;		Date :		18th August 2019
;		Review : 	4th September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									Copy 2nd item to 1st
;
; *******************************************************************************************

FPUCopyX2ToX1:
		pha									; save AXY
		phx
		phy
		ldy 	#8 							; copy the whole mantissa
_FPUC21:lda 	XS2_Mantissa,x
		sta 	XS_Mantissa,x
		inx
		dey
		bpl 	_FPUC21
		ply 								; restore and exit
		plx
		pla
		rts

; *******************************************************************************************
;
;							Sign Extend A and put in current level.
;
; *******************************************************************************************

FPUSetInteger:
		pha
		sta 	XS_Mantissa,x 				; set the lowest byte.
		and 	#$80 						; make this $00 or $FF dependent on MSB
		bpl 	_FPUSIExtend 				; so sign extend it into the mantissa
		lda 	#$FF
_FPUSIExtend:		
		sta 	XS_Mantissa+1,x 			; copy into the rest of the mantissa
		sta 	XS_Mantissa+2,x
		sta 	XS_Mantissa+3,x
		lda 	#1 			 				; type is integer (set bit 0)
		sta 	XS_Type,x
		pla
		rts

; *******************************************************************************************
;
;								Negate current as an integer.
;
; *******************************************************************************************

FPUNegateInteger:
		pha
		sec
		lda 	#0 							; simple 32 bit subtraction.
		sbc 	XS_Mantissa+0,x
		sta 	XS_Mantissa+0,x
		lda 	#0
		sbc 	XS_Mantissa+1,x
		sta 	XS_Mantissa+1,x
		lda 	#0
		sbc 	XS_Mantissa+2,x
		sta 	XS_Mantissa+2,x
		lda 	#0
		sbc 	XS_Mantissa+3,x
		sta 	XS_Mantissa+3,x
		pla
		rts

; *******************************************************************************************
;
;								Convert Integer to Float
;
; *******************************************************************************************

FPUToFloat:
		pha
		lda 	XS_Type,x					; exit if already float.
		and 	#$0F 						; (e.g. type is zero)
		beq 	_FPUFExit
		;
		;		Set type, and default exponent of 2^32
		;
		lda 	#0  						; zero the type byte, making it a float.
		sta 	XS_Type,x
		lda 	#128+32 					; and the exponent to 32, makes it * 2^32
		sta 	XS_Exponent,x 				; x mantissa.
		;
		;		If -ve integer, negate it and set the sign bit.
		;
		lda 	XS_Mantissa+3,x 			; signed integer ?
		bpl		_FPUFPositive
		jsr 	FPUNegateInteger 			; negate the mantissa
		lda 	#$80 						; set the sign flag.
		sta 	XS_Type,x
_FPUFPositive:		
		;
		lda 	XS_Mantissa,x 				; mantissa is zero ?
		ora 	XS_Mantissa+1,x
		ora 	XS_Mantissa+2,x
		ora 	XS_Mantissa+3,x
		bne 	_FPUFNonZero
		lda 	#$40 						; set the zero flag only in type byte
		sta 	XS_Type,x
_FPUFNonZero:
		;
		jsr 	FPUNormalise 				; normalise the floating point.
_FPUFExit:
		pla
		rts

; *******************************************************************************************
;
;									Normalise float 
;
; *******************************************************************************************

FPUNormalise:		
		pha
		bit 	XS_Type,x 					; if float-zero, don't need to normalise it.
		bvs 	_FPUNExit
		lda 	XS_Exponent,x 				; if exponent is zero, then make it zero.
		beq 	_FPUNSetZero 				; (e.g. the float value zero)
		;
		;		Normalising loop.
		;		
_FPUNLoop:
		lda 	XS_Mantissa+3,x 			; bit 31 of mantissa set.
		bmi 	_FPUNExit 					; if so, we are normalised.
		;
		#asl32x XS_Mantissa+0 				; shift mantissa left
		;
		dec 	XS_Exponent,x 				; decrement exponent
		bne 	_FPUNLoop 		 			; go round again until bit 31 set.
		; 									; if too small to normalise round to zero.
_FPUNSetZero:
		lda 	#$40
		sta 	XS_Type,x 					; the result is now zero.
_FPUNExit:
		pla
		rts
			
; *******************************************************************************************
;
;								Convert Float to Integer
;
; *******************************************************************************************

FPUToInteger:
		pha
		lda 	XS_Type,x 					; if already integer, exit
		and 	#1
		bne 	_FPUTOI_Exit
		;
		bit 	XS_Type,x					; if zero, return zero.
		bvs 	_FPUTOI_Zero		
		;
		lda 	XS_Exponent,x 				; if exponent 00-7F 
		bpl 	_FPUToI_Zero 				; the integer value will be zero (< 1.0)
		;
		cmp 	#128+32 					; sign exponent >= 32, overflow.
		bcs 	FP_Overflow 				; can't cope with that as an integer.
		;									
		; 		inverse of the toFloat() operation. shift back to exponent 32.
		;
_FPUToIToInteger:
		lda 	XS_Exponent,x 				; keep right shifting until reached 2^32
		cmp 	#128+32
		beq 	_FPUToICheckSign 			; check sign needs fixing up.
		inc 	XS_Exponent,X 				; increment Exponent
		#lsr32x XS_Mantissa	 				; shift mantissa right
		bra 	_FPUToIToInteger 			; keep going.
		;
		;		Apply sign in type to the integer value.
		;
_FPUToICheckSign:
		lda 	XS_Type,x 					; check sign
		bpl 	_FPUToI_Exit 				; exit if unsigned.
		jsr 	FPUNegateInteger 			; otherwise negate the shifted mantissa
		bra 	_FPUTOI_Exit
		;
_FPUTOI_Zero:
		lda 	#0 							; return zero integer.
		sta 	XS_Mantissa+0,x	
		sta 	XS_Mantissa+1,x
		sta 	XS_Mantissa+2,x	
		sta 	XS_Mantissa+3,x
		;
_FPUToI_Exit:
		lda 	#1 							; set type to integer
		sta 	XS_Type,x
		pla
		rts
FP_Overflow:
		#fatal 	"Floating Point overflow"

; *******************************************************************************************
;
;									Multiply by 10
;
; *******************************************************************************************

FPUTimes10:
		lda 	XS_Mantissa+0,x 			; copy mantissa to ZLTemp1
		sta 	ZLTemp1+0
		lda 	XS_Mantissa+1,x
		sta 	ZLTemp1+1
		lda 	XS_Mantissa+2,x
		sta 	ZLTemp1+2
		lda 	XS_Mantissa+3,x
		sta 	ZLTemp1+3
		;
		jsr 	_FPUT_LSR_ZLTemp1 			; divide ZLTemp1 by 4
		jsr 	_FPUT_LSR_ZLTemp1   		
		;
		clc
		lda 	XS_Mantissa+0,x 			; add n/4 to n
		adc 	ZLTemp1+0
		sta 	XS_Mantissa+0,x
		lda 	XS_Mantissa+1,x
		adc 	ZLTemp1+1
		sta 	XS_Mantissa+1,x
		lda 	XS_Mantissa+2,x
		adc 	ZLTemp1+2
		sta 	XS_Mantissa+2,x
		lda 	XS_Mantissa+3,x
		adc 	ZLTemp1+3
		sta 	XS_Mantissa+3,x

		bcc 	_FPUTimes10
		ror32x	XS_Mantissa,x				; rotate carry back into mantissa
		inc 	XS_Exponent,x				; fix exponent
_FPUTimes10:
		lda 	XS_Exponent,x 				; fix up x 2^3 e.g. multiply by 8.
		clc
		adc 	#3
		sta 	XS_Exponent,x
		bcs 	FP_Overflow 				; error
		rts

_FPUT_LSR_ZLTemp1:
		lsr 	ZLTemp1+3
		ror 	ZLTemp1+2
		ror 	ZLTemp1+1
		ror 	ZLTemp1+0
		rts

; *******************************************************************************************
;
;								Scale current expression TOS by 10^AC
;
; *******************************************************************************************

FPUScale10A:
		phy
		cmp 	#0 							; if A = 0, nothing to scale
		beq 	_FPUScaleExit
		;
		phx 								; save X
		inx6 								; next slot in expression stack.
		tay 								; save power scalar in Y.
		lda 	#0
		sta 	XS_Mantissa+0,x 			; set slot to 1.0 in float.
		sta 	XS_Mantissa+1,x
		sta 	XS_Mantissa+2,x
		sta 	XS_Type,x
		lda 	#$80
		sta 	XS_Mantissa+3,x
		lda 	#$81
		sta 	XS_Exponent,x
		;
		phy 								; save 10^n (e.g. the scalar) on stack.
		cpy 	#0
		bpl 	_FPUSAbs 					; set Y = |Y|, we want to multiply that 1.0 x 10		
		tya
		eor 	#$FF
		inc 	a
		tay
_FPUSAbs: 									; multiply the 1.0 by 10 Y times
		jsr 	FPUTimes10 
		dey
		bne 	_FPUSAbs 					; tos is now 10^|AC|
		;
		pla 								; restore count in A
		plx 								; restore X pointing to number to scale.
		asl 	a 
		bcs 	_FPUSDivide 				; if bit 7 of count set, divide
		jsr 	FPMultiply 					; if clear multiply.
		bra		_FPUScaleExit
_FPUSDivide:
		jsr 	FPDivide
_FPUScaleExit:		
		ply
		rts

; *******************************************************************************************
;
;								Copy TOS to next empty slot
;
; *******************************************************************************************

FPUCopyToNext:
		ldy 		#6 						
		phx
_FPUCopy1:
		lda 	XS_Mantissa,x
		sta 	XS2_Mantissa,x
		inx
		dey
		bne 	_FPUCopy1
		plx
		rts

; *******************************************************************************************
;
;								Copy TOS from next empty slot
;
; *******************************************************************************************

FPUCopyFromNext:
		ldy 		#6
		phx
_FPUCopy1:
		lda 	XS2_Mantissa,x
		sta 	XS_Mantissa,x
		inx
		dey
		bne 	_FPUCopy1
		plx
		rts
		