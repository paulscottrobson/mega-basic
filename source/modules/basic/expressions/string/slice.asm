; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		slice.asm
;		Purpose :	Slice strings.
;		Date :		22nd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************
;
;							Left, Right and Mid all use the same code.
;									Just add default values
;
; *******************************************************************************************

Unary_Mid:		;; mid$(
		jsr 	EvaluateStringX 				; get string.
		lda 	XS_Mantissa+0,x 				; push address on stack
		pha
		lda 	XS_Mantissa+1,x
		pha
		jsr 	CheckNextComma 					; skip comma
		jsr 	SLIByteParameter 				; get a byte parameter (start)
		pha 									; and push it.
		jsr 	CheckNextComma 					; skip comma
		jsr 	SLIByteParameter 				; get a byte parameter (#chars)
		pha 									; and push it.
		bra 	SLIProcess

Unary_Left:		;; left$(
		jsr 	EvaluateStringX 				; get string.
		lda 	XS_Mantissa+0,x 				; push address on stack
		pha
		lda 	XS_Mantissa+1,x
		pha
		lda 	#1 								; push start position (1)
		pha
		jsr 	CheckNextComma 					; skip comma
		jsr 	SLIByteParameter 				; get a byte parameter (# chars)
		pha 									; and push it.
		bra 	SLIProcess

Unary_Right:	;; right$(
		jsr 	EvaluateStringX 				; get string.
		lda 	XS_Mantissa+0,x 				; push address on stack
		pha
		lda 	XS_Mantissa+1,x
		pha

		phx 									; get the string length and push on stack.
		ldx 	#0
		lda		(zGenPtr,x)
		plx
		pha

		jsr 	CheckNextComma 					; skip comma
		jsr 	SLIByteParameter 				; get a byte parameter.
		;
		sta 	SignCount 						; save in temporary.
		;
		pla 									; restore string length.
		inc 	a 								; we add one. length 5, right 2, we start at 4.
		sec
		sbc 	SignCount 						; subtract characters needed, gives start position.
		beq 	_URStart 						; if <= 0 start from 1.
		bpl 	_UROkay
_URStart:
		lda 	#1		
_UROkay:
		pha 									; push start
		lda 	SignCount 						; push count of characters
		pha
		bra 	SLIProcess

; *******************************************************************************************
;
;			Process string slice. On stack [Count] [Start] [Str.Hi] [Str.Lo]
;		
; *******************************************************************************************

SLIProcess:
		jsr 	CheckNextRParen 				; closing right bracket.
		pla 	
		sta 	SliceCount 						; count in signcount
		inc 	a 								; allocate +1 for it.
		jsr 	AllocateTempString
		;		
		pla 									; pop start number off stack.
		beq 	SLIError 						; exit if start = 0
		sta 	SliceStart 

		pla  									; pop string address.
		sta 	zGenPtr+1
		pla
		sta 	zGenPtr
		phx
		phy
		ldx 	#0 								; point to string length.
		ldy 	SliceStart 						; start of the string (+1 for count)
_SLICopy:
		lda 	SliceCount 						; done count characters
		beq 	_SLIExit
		dec 	SliceCount
		;
		tya 									; index of character
		cmp 	(zGenPtr,x)						; compare against length
		beq 	_SLIOk 							; if equal, okay.
		bcs 	_SLIExit 						; if past end, then exit.
_SLIOk:	lda 	(zGenPtr),y 					; copy one character		
		iny
		jsr 	WriteTempString 			
		bra 	_SLICopy 						; go round till copied characters
		;
_SLIExit:
		ply 									; restore YX
		plx
		jmp 	UnaryReturnTempStr 				; return new temporary string.

		nop
;
;						Get a single parameter, must be a byte 0-255
;
SLIByteParameter:
		jsr 	EvaluateIntegerX 				; get integer
		;
		lda 	XS_Mantissa+1,x 				; check high bytes zero
		ora 	XS_Mantissa+2,x
		ora 	XS_Mantissa+3,x
		bne 	SLIError
		lda 	XS_Mantissa+0,x
		rts		
SLIError:
		jmp 	BadParamError
