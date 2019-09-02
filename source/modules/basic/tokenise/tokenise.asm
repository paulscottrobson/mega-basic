; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		tokenise.asm
;		Purpose :	Tokenise ASCII string
;		Date :		2nd September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;					Tokenise ASCIIZ string at (zGenPtr). Return length in A
;
; *******************************************************************************************
	
TokeniseString:
		sta 	zGenPtr 					; save source 
		stx 	zGenPtr+1
		ldy 	#0 							; source
		ldx 	#0 							; target
		;
		;		Main tokenising loop
		;
_TSMainLoop:
		;		
_TSSkipSpaces:
		lda 	(zGenPtr),y					; skip over spaces.
		iny
		cmp 	#" "
		beq 	_TSSkipSpaces 				
		;
		cmp 	#"0" 						; is it a constant
		bcc 	_TSNotConstant
		cmp 	#"9"+1
		bcs 	_TSNotConstant
		;
		dey 								; point back to start
		jsr 	TokeniseConstant 			; tokenise a constant
		bra 	_TSMainLoop			 		; and loop back.
_TSNotConstant:
		;
		cmp 	#32 						; end of line.
		bcc 	_TSExit
		cmp		#'"'						; quoted string
		beq 	_TSQuotedString
		cmp 	#'.' 						; decimal.
		beq 	_TSDecimal

_h1:	bra 	_h1

		;
		;		Tokenise, handle REM.
		;
_TSExit:lda 	#0 							; mark end of line.
		sta 	TokeniseBuffer,x 			
		txa 								; return length of tokenised line in bytes.
		rts
		;
		;		Quoted string, ended by either another " or a control.
		;
_TSQuotedString:
		jsr 	TokeniseQuotedString
		bra 	_TSMainLoop
		;
		;		Decimal sequence. 	
		;
_TSDecimal:		
		jsr 	TokeniseDecimalString
		bra 	_TSMainLoop
