; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		dec.asm
;		Purpose :	Convert string to number (hexadecimal)
;		Date :		22nd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Dec: 	;; dec(
		jsr 	EvaluateStringX 			; string parameter
		jsr 	CheckNextRParen 			; right bracket.
		;
		phy 		
		ldy 	#0 							; get length of hex string.
		lda 	(zGenPtr),y
		beq 	_UDFail 					; must fail if zero.
		sta 	SignCount 					; use SignCount as a counter of chars to process.
		;
		lda 	#0 							; set result to zero
		sta 	XS_Mantissa+0,x
		sta 	XS_Mantissa+1,x
		sta 	XS_Mantissa+2,x
		sta 	XS_Mantissa+3,x
		lda 	#1 							; set type to integer.
		sta 	XS_Type,x
		;
		;		Main Loop. Shift left 4 and OR digit in bottom.
		;
_UDConvertLoop:
		phy 								; shift mantissa left 4
		ldy 	#4 								
_UDShift:
		asl 	XS_Mantissa+0,x		
		rol 	XS_Mantissa+1,x		
		rol 	XS_Mantissa+2,x		
		rol 	XS_Mantissa+3,x		
		dey
		bne 	_UDShift
		ply 
		;
		iny 								; next character
		lda 	(zGenPtr),y 				; fetch it.
		jsr 	ConvertUpper 				; convert to U/C
		cmp 	#"0" 						; range 0-9
		bcc 	_UDFail		
		cmp 	#"9"+1
		bcc 	_UDOkay
		sbc 	#7+"0" 						; A-F fudge
		bcc 	_UDFail 					; fails if between 9 and @
		cmp 	#16 						; must be < 16 as hexadecimal.
		bcs 	_UDFail
_UDOkay:
		and 	#15 						; nibble only
		ora 	XS_Mantissa+0,x 			; OR into the bottom byte.
		sta 	XS_Mantissa+0,x
		dec 	SignCount 					; do it for each character in the string.
		bne 	_UDConvertLoop
		ply
		rts
;
_UDFail:
		jmp 	BadParamError

; *******************************************************************************************
;
;								Convert A to Upper Case
;
; *******************************************************************************************

ConvertUpper:
		cmp 	#"a"
		bcc 	_CUExit
		cmp 	#"z"+1
		bcs 	_CUExit
		sec
		sbc 	#32
_CUExit:rts
