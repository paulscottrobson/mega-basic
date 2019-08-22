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
		nop
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
		bne 	_SLIBPError
		lda 	XS_Mantissa+0,x
		rts		
_SLIBPError:
		#Fatal	"Bad String Slice"
