; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		val.asm
;		Purpose :	Convert string to number
;		Date :		22nd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Val: 	;; val(
		jsr 	EvaluateStringX 			; get string
		jsr 	CheckNextRParen 			; check right bracket.
		;
		;		Convert to ASCIIZ first
		;
		lda 	XS_Mantissa+0,x 			; put string address +1 into zGenPtr
		sta 	zGenPtr
		lda 	XS_Mantissa+1,x
		sta 	zGenPtr+1
		;
		;		Create a working buffer for the ASCIIZ string.
		;
		phy
		ldy 	#0 							; get count of characters.
		lda 	(zGenPtr),y  				; if zero, it's bad obviously :)
		beq 	_UVBadNumber
		;
		pha 								; save length.
		inc 	a 							; one for the length, one for the terminator
		inc 	a 							; null
		jsr 	AllocateTempString
		;
		; 		Check to see if there is a - sign up front.
		;
		iny 								; move to the next.
		lda 	(zGenPtr),y 				; get character
		eor 	#"-"						; zero if minus sign
		sta 	ValSign 					; store this in the val temp.
		bne 	_UVNotMinus
		iny 								; skip over it.
		pla 								; decrement character count.
		dec 	a
		beq 	_UVBadNumber 				; if there was only a '-' that's an error.
		pha
_UVNotMinus:		
		;
		;		Copy the number into the temporary string space.
		;
		pla 								; this is the count.
_UVCopy:pha									; copy into new temp string which is ASCIIZ
		lda 	(zGenPtr),y		
		iny 								
		jsr 	WriteTempString
		pla  	
		dec 	a
		bne 	_UVCopy 					; when finished copying A = 0 so
		jsr 	WriteTempString 			; make it ASCIIZ
		;
		;		Copy the temporary string address => genptr
		;
		clc
		lda 	zTempStr 					; tempstring +1 => genptr
		adc 	#1
		sta 	zGenPtr
		lda 	zTempStr+1
		adc 	#0
		sta 	zGenPtr+1
		;
		;		Convert integer.
		;
		clc
		jsr 	IntFromString 				; first bit.
		bcs 	_UVBadNumber
		;
		;		Convert float
		;
		.if 	hasFloat=1 					; float only !
		jsr 	FPFromString				; try for a float part - if float basic.
		.endif

		lda 	ValSign 					; was it negative
		bne 	_UVNotNegative
		;
		;		Negate the result.
		;
		lda 	XS_Type,x 					; check if integer
		lsr 	a
		bcs 	_UVInteger
		;
		;		If float, set the sign bit.
		;
		lda 	XS_Type,x 					; set sign bit
		ora 	#$80
		sta 	XS_Type,x
		bra 	_UVNotNegative
		;
		;		If integer, call the function.
		;		
_UVInteger:
		jsr 	IntegerNegateAlways 		; sign it.
_UVNotNegative:		

		lda 	(zGenPtr),y 				; used everything up ?
		bne 	_UVBadNumber
		ply
		rts
;
_UVBadNumber:
		jmp 	BadParamError
		