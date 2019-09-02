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
		dey 								; point to character
		;
		jsr 	TokeniseKeyword 			; try to tokenise a keyword.
		bcs 	_TSMainLoop					; true if tokenised okay.
		;
		lda 	(zGenPtr),y 				; get character
		jsr 	TOKCapitalise
		cmp 	#"A"						; is it A-Z, if so it's an alphanumeric sequence.
		bcc 	_TSSingle
		cmp 	#"Z"+1
		bcc 	_TSAlphaNumeric
		;
_TSSingle:		
		iny 								; skip over output
		and 	#63 						; make 6 bit ASCII
		ora 	#128
		beq 	_TSMainLoop 				; ignore @, which doesn't tokenise.
		sta 	TokeniseBuffer,x
		inx
		bra 	_TSMainLoop
		;
		;		Copy an alphanumeric sequence that follows.
		;
_TSAlphaNumeric:
		lda 	(zGenPtr),y 				; get 
		jsr 	TOKCapitalise
		cmp 	#"0" 	 					; check 0-9
		bcc 	_TSMainLoop
		cmp 	#"9"+1
		bcc 	_TSANOkay
		cmp 	#"A"						; check A-Z
		bcc 	_TSMainLoop
		cmp 	#"Z"+1
		bcs 	_TSMainLoop
		and 	#63 						; write it out
_TSANOkay:		
		sta 	TokeniseBuffer,x
		inx
		iny
		bra 	_TSAlphaNumeric
		;		
		;		Add NULL and exit.
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

;
;		Token capitaliser.
;
TOKCapitalise:
		cmp 	#"a"
		bcc 	_TOKCExit
		cmp 	#"z"+1
		bcs 	_TOKCExit
		eor 	#$20
_TOKCExit:
		rts		
