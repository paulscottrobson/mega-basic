; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		intfromstr.asm
;		Purpose :	Convert String to integer
;		Date :		18th August 2019
;		Review : 	5th September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;		Convert string at GenPtr into X1. Return CC if okay, CS on error
;		On successful exit Y is the characters consumed from the string. Does not
;		support - (done by unary operator)
;
; *******************************************************************************************

IntFromString:
		ldy 	#0 							; from (zGenPtr)
IntFromStringY:								; from (zGenPtr),y
		lda 	#0
		sta 	ExpTemp 					; this is the converted digit count.
		pha
		lda 	#0 							; clear the mantissa
		sta 	XS_Mantissa,x 				; (the number converted goes here)
		sta 	XS_Mantissa+1,x
		sta 	XS_Mantissa+2,x
		sta 	XS_Mantissa+3,x
		lda 	#1 							; sete type to integer
		sta 	XS_Type,x
;
;		Main conversion loop
;
_IFSLoop:		
		lda 	(zGenPtr),y 				; get next
		cmp 	#"0"						; validate it as range 0-9
		bcc 	_IFSExit
		cmp 	#"9"+1
		bcs 	_IFSExit
		;
		lda 	XS_Mantissa+3,x 			; is High Byte > $7F/10
		cmp 	#12 						; (approximately)
		bcs 	_IFSOverflow
		;
		;		Multiply mantissa by 10
		;
		lda 	XS_Mantissa+3,x 			; push mantissa on stack backwards
		pha
		lda 	XS_Mantissa+2,x
		pha
		lda 	XS_Mantissa+1,x
		pha
		lda 	XS_Mantissa+0,x
		pha
		jsr 	IFSX1ShiftLeft 				; double
		jsr 	IFSX1ShiftLeft 				; x 4
		;
		clc 								; add saved value x 5
		pla 
		adc 	XS_Mantissa+0,x 			
		sta 	XS_Mantissa+0,x
		pla
		adc 	XS_Mantissa+1,x
		sta 	XS_Mantissa+1,x
		pla
		adc 	XS_Mantissa+2,x
		sta 	XS_Mantissa+2,x
		pla
		adc 	XS_Mantissa+3,x
		sta 	XS_Mantissa+3,x
		jsr 	IFSX1ShiftLeft 				; x 10
		;
		inc 	ExpTemp 					; bump count of digits processed.
		;
		;		Add the new value in.
		;
		lda 	(zGenPtr),y 				; add digit
		and 	#15
		iny
		adc 	XS_Mantissa+0,x
		sta 	XS_Mantissa+0,x
		bcc 	_IFSLoop
		inc 	XS_Mantissa+1,x 			; propogate carry round.
		bne 	_IFSLoop
		inc 	XS_Mantissa+2,x 		
		bne 	_IFSLoop
		inc 	XS_Mantissa+3,x		
		bra 	_IFSLoop
_IFSExit:
		tya 								; get offset
_IFSOkay:		
		sec
		lda 	ExpTemp 					; if no digits processed, no integer here.
		beq 	_IFSSkipFail
		clc
_IFSSkipFail:		
		pla 								; and exit.
		rts

_IFSOverflow:
		jsr 	ERR_Handler
		.text 	"Constant overflow",0		
;
;		Double Mantissa,X
;
IFSX1ShiftLeft:
		asl 	XS_Mantissa+0,x
		rol 	XS_Mantissa+1,x
		rol 	XS_Mantissa+2,x
		rol 	XS_Mantissa+3,x
		rts
