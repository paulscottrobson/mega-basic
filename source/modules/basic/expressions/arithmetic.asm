; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		arithmetic.asm
;		Purpose :	Expression Evaluation (Arithmetic)
;		Date :		21st August 2019
;		Review : 	1st September 2019
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
		lda 	XS_Type,x  					; and types together
		and 	XS2_Type,x
		and 	#2 							; if bit 1 set they are both strings
		bne 	_BOAString 					; so go do the string code.
		;
		;		This calls one type or another depending on the types involved.
		;		Integer build, just calls the integer routine
		;		Float build, calls integer if both integers, floats otherwise
		;		(in this case if it's an int and a float the int is converted.)
		;
		BinaryChoose 	FPAdd,AddInteger32
		rts
		;
_BOAString:
		jmp 	ConcatenateString 			; concatenate two strings.

BinaryOp_Subtract: 	;; 	-
		BinaryChoose 	FPSubtract,SubInteger32
		rts

BinaryOp_Multiply: 	;; 	*
		BinaryChoose 	FPMultiply,MulInteger32
		rts
;
;		Divide is different. We always do floats, because the result might
;		be a float, cf the BBC Micro. IntegerBasic does Integer obviously
;
BinaryOp_Divide: 	;; 	/
		.if hasFloat == 1
		jsr 	BinaryMakeBothFloat 	
		jsr 	FPDivide
		.else
		jsr 	DivInteger32
		.endif
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
		inx6 								; go to next mantissa, e.g. the RHS
		jsr 	BinaryMakeFloat 			; convert to float.
		plx 								; restore X and fall through.
		;
		;		Convert Mantissa,X to float if needed.
		;
BinaryMakeFloat:		
		lda 	XS_Type,x 					; get type byte.
		lsr 	a 							; if bit 0 set, it's integer so convert
		bcs 	_BMFConvert
		lsr 	a 							; if bit 1 set, it's a string so error (type)
		bcs 	_BMFError
		rts
;
_BMFConvert:
		.if 	hasFloat==1
		jmp 	FPUToFloat 					; convert to float, only float builds of course
		.endif

_BMFError:
		jmp 	TypeError
				
; *******************************************************************************************
;
;								Concatenate two strings
;
; *******************************************************************************************

ConcatenateString:
		lda 	XS_Mantissa+0,x 			; copy string addresses to ZLTemp and ZLTemp+2
		sta		zLTemp1+0
		lda 	XS_Mantissa+1,x
		sta 	zLTemp1+1
		lda 	XS2_Mantissa+0,x
		sta 	zLTemp1+2
		lda 	XS2_Mantissa+1,x
		sta 	zLTemp1+3
		;
		;		Work out the length of the target string and check it is legal.
		;
		phy
		ldy 	#0 							; work out total length.
		lda 	(zlTemp1),y
		adc 	(zlTemp1+2),y
		ply
		bcs 	_CSError					; check in range.
		cmp 	#maxString+1
		bcs 	_CSError
		;
		;		Allocate space then copy strings in.
		;
		jsr 	AllocateTempString 			; store the result
		jsr 	_CSCopyString 				; copy zlTemp1 string in.
		;
		lda 	XS2_Mantissa+0,x 			; point zLTemp1 to second string
		sta 	zLTemp1
		lda 	XS2_Mantissa+1,x
		sta 	zLTemp1+1
		jsr 	_CSCopyString 				; copy zlTemp1 string in.
		;
		;		Make the return value the temporary string just created.
		;
		lda 	zTempStr 					; point current to new string
		sta 	XS_Mantissa+0,x
		lda 	zTempStr+1
		sta 	XS_Mantissa+1,x
		rts
		;
		;		Copy string at ZLTemp1 to current temp string.
		;
_CSCopyString:		
		phx
		phy
		ldy 	#0 							; get length
		lda 	(zLTemp1),y 				
		beq 	_CSCSExit 					; if zero, exit immediately
		tax 								; put in X which is the counter.
_CSCSLoop:
		iny 								; get next char
		lda 	(zLTemp1),y
		jsr		WriteTempString 			; copy out to new string
		dex 								; do whole string
		bne 	_CSCSLoop
_CSCSExit:	
		ply
		plx
		rts

_CSError:
		#Fatal	"String too long"

