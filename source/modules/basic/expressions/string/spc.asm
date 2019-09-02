; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		spc.asm
;		Purpose :	String of spaces.
;		Date :		22nd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Spc: 	;;	spc(
		jsr 	SLIByteParameter 			; get number of spaces
		jsr 	CheckNextRParen 			; skip )
		;
		lda 	XS_Mantissa+0,x 			; count of spaces
UnarySpcCreate:		
		cmp 	#maxString+1				; validate
		bcs 	_USSize
		pha 								; save length
		inc 	a 							; allocate one more.
		jsr 	AllocateTempString		
		pla 								; get length
		beq 	UnaryReturnTempStr 			; if zero (spc(0)) return the current temp string
		;
_USLoop: 									; write out A spaces
		pha
		lda 	#" "
		jsr 	WriteTempString
		pla
		dec 	a
		bne 	_USLoop		
		bra 	UnaryReturnTempStr 			; and return the temporary space.
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
		;
		sta 	zTemp1 						; calculate required-current
		sec
		lda 	XS_Mantissa+0,x 			; return chars required.	
		sbc 	zTemp1
		bcs 	UnarySpcCreate 				; if not there, use SPC() code to generate string
		lda 	#0 							; if there or better, no characters required.
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

