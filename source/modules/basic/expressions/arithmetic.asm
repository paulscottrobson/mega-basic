; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		arithmetic.asm
;		Purpose :	Expression Evaluation (Arithmetic)
;		Date :		21st August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									Binary Operator Dispatchers
;
; *******************************************************************************************

BinaryOp_Add:		;; 	+
		BinaryChoose 	FPAdd,AddInteger32
		rts

BinaryOp_Subtract: 	;; 	-
		BinaryChoose 	FPSubtract,SubInteger32
		rts

BinaryOp_Multiply: 	;; 	*
		BinaryChoose 	FPMultiply,MulInteger32
		rts

BinaryOp_Divide: 	;; 	/
		BinaryChoose 	FPDivide,DivInteger32
		rts

; *******************************************************************************************
;
;									Integer arithmetic routines
;
; *******************************************************************************************

AddInteger32:
		clc
		lda 	XS_Mantissa+0,x
		adc 	XS2_Mantissa+0,x
		sta 	XS_Mantissa+0,x
		lda 	XS_Mantissa+1,x
		adc 	XS2_Mantissa+1,x
		sta 	XS_Mantissa+1,x
		lda 	XS_Mantissa+2,x
		adc 	XS2_Mantissa+2,x
		sta 	XS_Mantissa+2,x
		lda 	XS_Mantissa+3,x
		adc 	XS2_Mantissa+3,x
		sta 	XS_Mantissa+3,x
		rts

SubInteger32:
		sec
		lda 	XS_Mantissa+0,x
		sbc 	XS2_Mantissa+0,x
		sta 	XS_Mantissa+0,x
		lda 	XS_Mantissa+1,x
		sbc 	XS2_Mantissa+1,x
		sta 	XS_Mantissa+1,x
		lda 	XS_Mantissa+2,x
		sbc 	XS2_Mantissa+2,x
		sta 	XS_Mantissa+2,x
		lda 	XS_Mantissa+3,x
		sbc 	XS2_Mantissa+3,x
		sta 	XS_Mantissa+3,x
		rts

; *******************************************************************************************
;
;		Routine to convert types to float. Float is unchanged, Integer is converted
;		string causes error. Two versions, one does both, one one.
;
; *******************************************************************************************

BinaryMakeBothFloat:
		phx 								; save X
		inx6 								; go to next
		jsr 	BinaryMakeFloat 			; convert to float.
		plx 								; restore X and fall through.
BinaryMakeFloat:		
		lda 	XS_Type,x 					; get type byte.
		lsr 	a 							; if bit 0 set, it's integer so convert
		bcs 	_BMFConvert
		lsr 	a 							; if bit 1 set, it's a string so error (type)
		bcs 	_BMFError
		rts
;
_BMFConvert:
		.if 	hasFloat=1
		jmp 	FPUToFloat 					; convert to float		
		.endif
_BMFError:
		#Error
		.text 	"Numeric type required",0
				