; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		tokseq.asm
;		Purpose :	Tokenise ASCII string sequences.
;		Date :		2nd September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;					Tokenise Quoted string at (zGenPtr),y
;
; *******************************************************************************************
	
TokeniseQuotedString:
		stx 	zTemp1 						; save position
		lda 	#$FE 						; write marker
		sta 	TokeniseBuffer,x 			
		inx 								; bump, and one space for the count.
		inx
_TSQCopy:
		lda 	(zGenPtr),y		
		cmp 	#" "
		bcc 	SequenceExit 				; if < ' ' then exit, didn't find end.
		iny
		cmp 	#'"'						; if = quote, consume it and exit.
		beq 	SequenceExit
		sta 	TokeniseBuffer,x 			; write out and loop
		inx
		bra 	_TSQCopy		
		;
SequenceExit:
		txa 								; current position
		sec 								; subtract start.
		sbc 	zTemp1		
		phx 								; copy that in
		ldx 	zTemp1
		sta 	TokeniseBuffer+1,x
		plx
		rts

; *******************************************************************************************
;
;						Tokenise Decimal string at (zGenPtr),y
;
;		This is a sequence of numbers (possibly none), optionally followed by an exponent
;		which is E/e optional minus, and another sequence of numbers.
;
; *******************************************************************************************
	
TokeniseDecimalString:
		stx 	zTemp1 						; save position
		lda 	#$FD 						; write marker
		sta 	TokeniseBuffer,x 			
		inx 								; bump, and one space for the count.
		inx
		jsr 	_TDSCopyNumber 				; copy a number.
		;
		lda 	(zGenPtr),y	 				; next letter.
		jsr 	TOKCapitalise
		cmp 	#"E" 						; if not an exponent.
		bne 	SequenceExit 				; exit now.
		;
		sta 	TokeniseBuffer,x 			; write E out
		inx
		iny
		lda 	(zGenPtr),y 				; followed by a minus ?
		cmp 	#"-"
		bne 	_TDSNoMinusExponent
		sta 	TokeniseBuffer,x 			; write - out
		inx
		iny
_TDSNoMinusExponent:
		jsr 	_TDSCopyNumber 				; do the exponent
		bra 	SequenceExit 
;
;					Copy a digit sequence from the source to the buffer
;
_TDSCopyNumber:
		lda 	(zGenPtr),y
		cmp 	#"0"
		bcc 	_TDSCNExit
		cmp 	#"9"+1
		bcs 	_TDSCNExit
		sta 	TokeniseBuffer,x
		inx
		iny
		bra 	_TDSCopyNumber		
_TDSCNExit:
		rts		

		