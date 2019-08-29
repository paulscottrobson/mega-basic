; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		if.asm
;		Purpose :	IF/THEN IF/ELSE/ENDIF Command
;		Date :		29th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;		There are two types :-
;
;		IF <expr> THEN <command> 				(IF +1, THEN -1)
;
;		IF <expr> 								(IF +1, ENDIF -1)
;		<code>
;		ELSE 									(the ELSE clause is optional)
;		<code>
;		ENDIF
;
;		The first one is detected by the presence of the THEN keyword. If this is found, then 
; 		the expression is evaluated and the rest of the command skipped if it fails.
;		THEN allows THEN 50 as shorthand.
;
;		The second one is detected by the absence of THEN.
;		
;		(1)		the IF token is pushed on the stack.
;
;		(2a) 	if successful, execution continues until either ENDIF or ELSE
;				is found.
; 					ELSE 	check and throw the IF marker, scan forward to ENDIF at 
;							the same level.
;					ENDIF 	check and throw the IF marker, and continue.
;
;		(2b) 	if unsuccessful, scan forward to ELSE or ENDIF at the same level, and 
;				continue after that, throwing tos only if ENDIF is found.
;
; *******************************************************************************************

Command_IF: 	;; if
		jsr 	EvaluateInteger 			; check success.

		lda 	XS_Mantissa+0				; check the result if zero
		ora 	XS_Mantissa+1
		ora 	XS_Mantissa+2
		ora 	XS_Mantissa+3
		tax 								; put into X.

		#s_get 								; get the next thing
		cmp 	#token_Then 				; then found.
		bne 	_FIFExtended
		;
		; ************************************************************************************
		;
		;									IF ... THEN same line.
		;
		; ************************************************************************************
		;
		#s_next
		cpx 	#0 							; was it successful.
		beq 	_FIFEndOfLine 				; if not, go to the end of the line.
		;
		#s_get
		and 	#$C0 						; is it a number
		cmp 	#$40
		bne 	_FIFContinue 				; if not, do what ever follows.
		jmp		Command_GOTO 				; we have IF <expr> THEN <number> so we do GOTO code.
		;
		;		Skip the whole rest of the line.
		;
_FIFEndOfLine:
		#s_get 								; get next token
		cmp 	#0 							; if zero, end of line, so exit
		beq 	_FIFContinue
		#s_skipElement 						; go forward
		bra 	_FIFEndOfLine
		;		
_FIFContinue:
		rts
		;
		; ************************************************************************************
		;
		;							IF .... <ELSE> .... ENDIF code
		;
		; ************************************************************************************
		;
_FIFExtended:
		nop
		
;		inc 	DStack 						; put IF on the top of the stack
;		inc 	DStack
;		lda 	#ifTokenID 
;		ldx 	DStack
;		sta 	$00,x
;		;
;		tya 								; see if the test was passed.
;		beq 	_FIXSkip 					; if zero then it has failed.
;		rts 								; test passed, so continue executing
;		;
;		;		Test Failed.
;		;
;_FIXSkip:
;		lda 	#elseTokenID 				; scan forward till found either ELSE or ENDIF
;		ldx 	#endifTokenID 				; at the same level.
;		jsr 	ScanForwardLevel 			; scan forward, returns what found in A.
;		inc 	DCodePtr 					; skip over the ELSE or ENDIF
;		inc 	DCodePtr
;		cmp 	#endifTokenID 				; if ENDIF token ID, then throw the TOS as ended
;		bne 	_FIXNoThrow
;		dec 	DStack 						; throw the token IF on the stack top.
;		dec 	DStack
;_FIXNoThrow:
;		rts
		;
		;		ELSE. If you execute ELSE, then skip forward to the ENDIF on this level.
		;
Handler_ELSE:	;; else 
;		ldx 	DStack	 					; check the top of stack is IF.
;		lda 	$00,x
;		cmp 	#ifTokenID
;		bne 	_HEBadStructure
;		lda 	#endifTokenID 				; only searching one token.
;		ldx 	#$0000			
;		jsr 	ScanForwardLevel 			; so this will find the ENDIF
;		;
;		inc 	DCodePtr 					; skip over the ENDIF
;		inc 	DCodePtr
;
;		dec 	DStack 						; throw the token IF on the stack top.
;		dec 	DStack
;		rts

;_HEBadStructure:	
;		#error 	"Else without If"

		;
		;		ENDIF. If you execute ENDIF, then just test and throw TOS.
		;
Handler_ENDIF:	;; endif
;		ldx 	DStack	 					; check the top of stack is IF.
;		lda 	$00,x
;		cmp 	#ifTokenID
;		bne 	_HEIBadStructure
;		;
;		dec 	DStack 						; throw the token IF on the stack top.
;		dec 	DStack
;		rts

;_HEIBadStructure:	
;		#error 	"Else without If"

		