; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		str.asm
;		Purpose :	Convert number to string
;		Date :		22nd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Str: 	;; str$(
		jsr 	EvaluateNumberX 			; numeric parameter
		jsr 	CheckNextRParen 			; right bracket.
		;
		;		Use the correct function to convert to a string.
		;
		lda 	#0 							; reset buffer index
		sta 	NumBufX
		lda 	XS_Type,x 					; get type
		lsr 	a 							; bit 0 identifies an integer.
		bcs 	_USInt 						; if msb set do as integer
		.if 	hasFloat==1 
		jsr 	FPToString 					; call fp to str otherwise
		.fi
		bra 	_USDuplicate
_USInt:	jsr 	IntToString					; call int to str.
		;
		;		We have a result, in the number buffer, so we create a temporary
		;		string out of it
		;
_USDuplicate:
		lda 	NumBufX 					; chars in buffer
		inc 	a 							; one more for length
		jsr 	AllocateTempString 			; allocate space for it.
		;
		phy 								; save Y
		ldy 	#0 							; start copying
_USCopy:lda 	Num_Buffer,y 				; get and write
		jsr 	WriteTempString
		iny
		cpy 	NumBufX 					; done the lot
		bne 	_USCopy
		ply 								; restore Y
		;
		jmp 	UnaryReturnTempStr 			; return newly created temporary string.

