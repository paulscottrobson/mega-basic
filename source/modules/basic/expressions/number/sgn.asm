; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		sgn.asm
;		Purpose :	Sgn( unary function
;		Date :		22nd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Sgn:	;; 	sgn(
		jsr 	EvaluateNumberX 			; get value
		jsr 	CheckNextRParen 			; check right bracket.
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
		lda 	#$FF
		sta 	XS_Mantissa,x
		bra 	UnarySetAFill
UnarySetAInteger:		
		sta 	XS_Mantissa,x
		lda 	#0
UnarySetAFill:		
		sta 	XS_Mantissa+1,x
		sta 	XS_Mantissa+2,x
		sta 	XS_Mantissa+3,x
		lda 	#1
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
		bcc 	_GSCFloat 					
		;
		lda 	XS_Mantissa+3,x
		bmi 	_GSCMinus1
		ora 	XS_Mantissa+0,x
		ora 	XS_Mantissa+1,x
		ora 	XS_Mantissa+2,x
		bne 	_GSCPlus1
_GSCZero:
		lda 	#0
		rts
_GSCPlus1:				
		lda 	#$01
		rts
_GSCMinus1:				
		lda 	#$FF
		rts
		;
_GSCFloat:
		bit 	XS_Type,x 
		bvs 	_GSCZero
		bmi 	_GSCMinus1
		bra 	_GSCPlus1		
		