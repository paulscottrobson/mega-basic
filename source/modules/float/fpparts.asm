; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fpparts.asm
;		Purpose :	Get Fractional/Integer part of a float.
;		Date :		18th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;								Get Fractional Part
;
; *******************************************************************************************

FPFractionalPart:
		lda 	XS_Exponent,x 				; if exponent $00-$7F then unchanged as fractional.
		sec 								; this flag tells us to keep the fractional part
		bmi 	FPGetPart
		rts

; *******************************************************************************************
;
;								Get Integer Part
;
; *******************************************************************************************

FPIntegerPart:
		lda 	XS_Exponent,x 				; if exponent -ve then the result is zero (must be < 1.0)
		clc 								; this flag says keep the integer part.
		bmi 	FPGetPart 					; -ve exponents are 0..127
		pha
		lda 	#$40 						; set the Zero Flag
		sta 	XS_Type,x 					
		pla
		rts

; *******************************************************************************************
;
;									Get one part or the other
;
; *******************************************************************************************

FPGetPart:
		pha
		phy 								; save Y
		;
		php 								; save action
		bit 	XS_Type,x 					; if zero, return zero for int and frac
		bvs 	_FPGP_Exit 					; then do nothing.
		;
		lda 	#$FF 						; set the mask long to -1
		sta 	zLTemp1+0 					; this mask is applied to chop out the 
		sta 	zLTemp1+1 					; bits you would keep/lose if it was exponent 32.
		sta 	zLTemp1+2
		sta 	zLTemp1+3
		;
		lda 	XS_Exponent,x				; the number of shifts.
		sec
		sbc 	#128 						; is the exponent value-128

		beq 	_FPGP_NoShift 				; ... if any
		cmp 	#32
		bcc 	_FPGP_NotMax
		lda 	#32 						; max of 32.
_FPGP_NotMax:		 	
		tay 								; Y is the mask shift count.

_FPGP_ShiftMask:		
		#lsr32	zLTemp1 					; shift mask right that many times.
		dey
		bne 	_FPGP_ShiftMask	
_FPGP_NoShift:
		;
		ldy 	#0 							; now mask each part in turn.
		stx 	ExpTemp						; save X
_FPGP_MaskLoop:
		lda 	zlTemp1,y 					; get mask byte
		plp 								; if CC we keep the top part, so we 
		php		 							; flip the mask.
		bcs		_FPGP_NoFlip
		eor 	#$FF
_FPGP_NoFlip:
		and 	XS_Mantissa,x 				; and into the mantissa.
		sta 	XS_Mantissa,x
		inx
		iny
		cpy 	#4 							; until done 32 bits.
		bne 	_FPGP_MaskLoop		
		ldx 	ExpTemp						; restore X
		;
		plp
		php 								; get action flag on the stack
		bcc 	_FPGP_NotFractional 		; if fractional part always return +ve.
		lda 	#0
		sta 	XS_Type,x
_FPGP_NotFractional:		
		;
		#iszero32x XS_Mantissa 				; is the result zero
		beq 	_FPGP_Zero 					; if zero, return zero
		;
		jsr 	FPUNormalise
		bra 	_FPGP_Exit 					; and exit
		;
_FPGP_Zero:
		lda 	#$40 						; set zero flag
		sta 	XS_Type,x
		;
_FPGP_Exit:
		pla 								; throw saved action flag.
		ply
		pla
		rts
