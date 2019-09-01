; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		sgn.asm
;		Purpose :	Sgn( unary function
;		Date :		22nd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Sgn:	;; 	sgn(
		jsr 	EvaluateNumberX 			; get value
		jsr 	CheckNextRParen 			; check right bracket.
		;
		jsr 	GetSignCurrent 				; get sign.
		ora 	#0
		bpl		UnarySetAInteger			; if 0,1 return that.
		bra 	UnarySetAMinus1 			; -1 return $FFFFF...	 	

; *******************************************************************************************
;
;						Helper routines to return an integer or -1
;
; *******************************************************************************************

UnarySetAMinus1:
		lda 	#$FF 						; put -1 in all four slots.
		sta 	XS_Mantissa,x
		bra 	UnarySetAFill
		;
UnarySetAInteger:		 					; put A in slot, 0 in all the rest
		sta 	XS_Mantissa,x
		lda 	#0
UnarySetAFill:		
		sta 	XS_Mantissa+1,x
		sta 	XS_Mantissa+2,x
		sta 	XS_Mantissa+3,x
		lda 	#1 							; set type to integer.
		sta 	XS_Type,x
		rts

; *******************************************************************************************
;
;										Get sign of current
;
; *******************************************************************************************

GetSignCurrent:
		lda 	XS_Type,x 					; identify type.
		lsr 	a 							; if LSB set it is integer.
		bcc 	_GSCFloat 					; if clear do the float code.
		;
		lda 	XS_Mantissa+3,x 			; if msb of integer set, it's negative
		bmi 	_GSCMinus1
		ora 	XS_Mantissa+0,x
		ora 	XS_Mantissa+1,x
		ora 	XS_Mantissa+2,x
		bne 	_GSCPlus1 					; check if zero by oring all together.
		;
_GSCZero:									; return 0
		lda 	#0
		rts
_GSCPlus1:									; return 1
		lda 	#$01
		rts
_GSCMinus1:									; return -1
		lda 	#$FF
		rts
		;
		;		Get float sign.
		;
_GSCFloat:
		bit 	XS_Type,x 					; check bits
		bvs 	_GSCZero 					; if zero flag set return zero
		bmi 	_GSCMinus1 					; if sign set return -1
		bra 	_GSCPlus1		 			; else return +1
				