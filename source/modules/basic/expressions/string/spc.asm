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
		jsr 	SLIByteParameter 			; check space.
		jsr 	CheckNextRParen
		;
		lda 	XS_Mantissa+0,x
UnarySpcCreate:		
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
;		TAB which is sort of 'from the current position'. Technically you are supposed
;		to print forward-moves not spaces.
;
; *******************************************************************************************

Unary_Tab: 	;; tab(
		ldx 	#0 							; required TAB position.
		jsr 	SLIByteParameter
		jsr 	CheckNextRParen
		jsr 	VIOCharGetPosition 			; were are we ?
		sta 	zTemp1
		sec
		lda 	XS_Mantissa+0 				; return chars required.	
		sbc 	zTemp1
		bcs 	UnarySpcCreate
		lda 	#0
		bra 	UnarySpcCreate

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
