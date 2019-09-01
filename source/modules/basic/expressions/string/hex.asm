; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		hex.asm
;		Purpose :	Convert number to string (hexadecimal)
;		Date :		22nd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Hex: 	;; hex$(
		jsr 	EvaluateIntegerX 			; numeric parameter
		jsr 	CheckNextRParen 			; right bracket.
		;
		lda 	#9 							; allocate 9 bytes (8 chars + length)
		jsr 	AllocateTempString			; allocate string space
		;
		lda 	XS_Mantissa+3,x 			; do each byte in turn.
		jsr 	_UHConvert	
		lda 	XS_Mantissa+2,x
		jsr 	_UHConvert	
		lda 	XS_Mantissa+1,x
		jsr 	_UHConvert	
		lda 	XS_Mantissa+0,x
		jsr 	_UHConvert	
		;
		phy 								; get length of new string 
		ldy 	#0
		lda 	(zTempStr),y
		ply
		cmp 	#0 							; if it was non zero okay
		bne 	_UHExit 					; otherwise suppressed all leading zeros !
		lda 	#"0" 						; empty, output one zero.
		jsr 	WriteTempString
_UHExit:		
		jmp 	UnaryReturnTempStr 			; return new temporary string.
;
;		Put A into temporary string.
;
_UHConvert:
		pha
		lsr 	a 							; do MSB
		lsr 	a
		lsr 	a
		lsr 	a
		jsr 	_UHNibble
		pla 								; do LSB
_UHNibble:
		and 	#15 						; get nibble
		bne 	_UHNonZero 					; if not zero, write it out anyway.
		;
		phy									; get the length
		ldy 	#0
		lda 	(zTempStr),y
		ply
		;
		cmp 	#0 							; length = 0 => suppress leading zeros.
		beq 	_UHExit2
		lda 	#0 							; length > 0, so can't suppress any more.
_UHNonZero:
		cmp 	#10 						; convert to ASCII
		bcc 	_UHDigit
		adc 	#7-1
_UHDigit:
		adc 	#48
		jsr 	WriteTempString				; output to temp string.
_UHExit2:
		rts		

		