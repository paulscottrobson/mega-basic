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
		;		Check there's something there.
		;
		phx
		phy
		ldy 	#0 							; get count of characters.
		lda 	(zGenPtr),y  				; if zero, it's bad obviously :)
		beq 	UVBadNumber
		;
		;		Copy into Num_Buffer
		;
		tax
_UVCopy1:		
		iny 
		cpy 	#24 						; too long
		beq 	UVBadNumber
		lda 	(zGenPtr),y					; copy character	
		sta 	Num_Buffer-1,y
		lda 	#0 							; make string ASCIIZ.
		sta 	Num_Buffer,y
		dex
		bne 	_UVCopy1
		ply
		plx
		jsr 	ConvertNumBuffer 			; convert string in NumBuffer to mantissa,x
		rts

UVBadNumber:
		#Fatal	"Bad Number"

; *******************************************************************************************
;
;						Convert ASCIIZ number in Num_Buffer to Mantissa,X
;
; *******************************************************************************************

ConvertNumBuffer:
		phy

		lda 	#Num_Buffer & $FF 			; set zGenPtr to point to buffer.
		sta 	zGenPtr
		lda 	#Num_Buffer >> 8
		sta 	zGenPtr+1
		;
		lda 	Num_Buffer 					; first character is - ?
		cmp 	#"-"
		bne 	_UVNotMinus1
		inc 	zGenPtr 					; this time just fix the pointer.
_UVNotMinus1:

		jsr 	IntFromString 				; get integer
		bcs 	UVBadNumber
		.if 	hasFloat != 0
		jsr 	FPFromString 				; possibly float it.
		.endif

		lda 	(zGenPtr),y 				; done the whole string
		bne 	UVBadNumber 				; no, exit.

		lda 	Num_Buffer 					; look at numbuffer
		cmp 	#"-"
		bne 	_UVNotMinus2

		lda 	XS_Type,x 					; type is float ?
		and 	#$0F
		beq 	_UVNegateFloat
		jsr 	IntegerNegateAlways
		bra 	_UVNotMinus2
_UVNegateFloat:
		lda 	XS_Type,x 					; set the sign bit.	
		ora 	#$80
		sta 	XS_Type,x
_UVNotMinus2:
		ply
		rts

		