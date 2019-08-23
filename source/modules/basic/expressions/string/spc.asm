; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		spc.asm
;		Purpose :	String of spaces.
;		Date :		22nd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Spc: 	;;	spc(
		jsr 	EvaluateIntegerX 			; numeric parameter
		jsr 	CheckNextRParen 			; right bracket.
		;
		lda 	XS_Mantissa+1,x 			; check upper bytes 0
		ora 	XS_Mantissa+2,x
		ora 	XS_Mantissa+3,x
		bne 	_USSize
		;
		lda 	XS_Mantissa+0,x
		cmp 	#maxString+1
		bcs 	_USSize
		pha 								; save length
		inc 	a 							; allocate one more.
		jsr 	AllocateTempString		
		pla 								; get length
		beq 	UnaryReturnTempStr 			; return the current temp string
_USLoop: 									; write out A spaces
		pha
		lda 	#" "
		jsr 	WriteTempString
		pla
		dec 	a
		bne 	_USLoop		
		bra 	UnaryReturnTempStr
_USSize:
		jmp 	BadParamError

; *******************************************************************************************
;
;							Return last defined temporary string
;
; *******************************************************************************************

UnaryReturnTempStr:
		lda 	zTempStr 					; copy temp string addr -> mantissa
		sta 	XS_Mantissa+0,x
		lda 	zTempStr+1
		sta 	XS_Mantissa+1,x
		lda 	#2 							; set type to string
		sta 	XS_Type,x
		rts
