; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		logical.asm
;		Purpose :	Binary Logical Operators
;		Date :		21st August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									Logical Binary Operators
;
; *******************************************************************************************

BinaryOp_And:		;; 	and
		jsr 	BinaryMakeBothInteger
		;
		lda		XS_Mantissa+0,x
		and 	XS2_Mantissa+0,x
		sta 	XS_Mantissa+0,x
		lda		XS_Mantissa+1,x
		and 	XS2_Mantissa+1,x
		sta 	XS_Mantissa+1,x
		lda		XS_Mantissa+2,x
		and 	XS2_Mantissa+2,x
		sta 	XS_Mantissa+2,x
		lda		XS_Mantissa+3,x
		and 	XS2_Mantissa+3,x
		sta 	XS_Mantissa+3,x
		rts

BinaryOp_Or:		;; 	or
		jsr 	BinaryMakeBothInteger
		;
		lda		XS_Mantissa+0,x
		ora 	XS2_Mantissa+0,x
		sta 	XS_Mantissa+0,x
		lda		XS_Mantissa+1,x
		ora 	XS2_Mantissa+1,x
		sta 	XS_Mantissa+1,x
		lda		XS_Mantissa+2,x
		ora 	XS2_Mantissa+2,x
		sta 	XS_Mantissa+2,x
		lda		XS_Mantissa+3,x
		ora 	XS2_Mantissa+3,x
		sta 	XS_Mantissa+3,x
		rts

BinaryOp_Eor:		;; 	eor
BinaryOp_Xor:		;; 	xor

		jsr 	BinaryMakeBothInteger
		;
		lda		XS_Mantissa+0,x
		eor 	XS2_Mantissa+0,x
		sta 	XS_Mantissa+0,x
		lda		XS_Mantissa+1,x
		eor 	XS2_Mantissa+1,x
		sta 	XS_Mantissa+1,x
		lda		XS_Mantissa+2,x
		eor 	XS2_Mantissa+2,x
		sta 	XS_Mantissa+2,x
		lda		XS_Mantissa+3,x
		eor 	XS2_Mantissa+3,x
		sta 	XS_Mantissa+3,x
		rts

; *******************************************************************************************
;
;						Routine to convert both types to integer
;
; *******************************************************************************************

BinaryMakeBothInteger:
		phx 								; save X
		inx6 								; go to next
		jsr 	BinaryMakeInteger 			; convert to integer.
		plx 								; restore X and fall through.
BinaryMakeInteger:		
		lda 	XS_Type,x 					; get type byte.
		and 	#15 						; check type zero
		beq 	_BMIConvert 				; if float convert to integer.
		lsr 	a 							; if bit 0 clear it's not an integer
		bcc 	_BMIError
		rts
;
_BMIConvert:
		.if 	hasFloat=1
		jmp 	FPUToInteger 				; convert to integer		
		.endif
_BMIError:
		#Fatal	"Numeric type required"
				