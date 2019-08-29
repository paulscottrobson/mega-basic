; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		while.asm
;		Purpose :	WHILE/WEND
;		Date :		29th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Command_WHILE: ;; while
		jsr 	StackSavePosition			; save position into stack, but don't yet push.
		jsr 	EvaluateInteger 			; calculate the while loop value.
		lda 	XS_Mantissa+0				; check the result if zero
		ora 	XS_Mantissa+1
		ora 	XS_Mantissa+2
		ora 	XS_Mantissa+3
		beq 	_CWHSkip 					; if it is zero, then skip to WEND.
		;
		lda 	#(SMark_While << 4)+SourcePosSize
		jsr 	StackPushFrame 				; push on stack
		rts
		;
_CWHSkip:
		lda 	#token_Wend 				; look for the WEND token.
		jsr 	StructureSearchWend
		rts

Command_WEND: ;; wend
		lda 	#(SMark_While << 4)			; remove the frame
		jsr 	StackPopFrame
		jsr 	StackRestorePosition 		
		bra 	Command_WHILE 				; and do the while again.
		rts

; *******************************************************************************************
;
;		Scan forward for a structure-close looking for A, tracking open/close 
;		program structure forwards.
;
; *******************************************************************************************

StructureSearchWend:
		sta 	zTemp1 						; save the target on zTemp1
		lda 	#0 							; set the structure depth to zero (zTemp2)
		sta 	zTemp2
		bra 	_SSWLoop 					; jump in, start scanning from here.
		;
		;			Start a new line
		;
_SSWNextLine:
		#s_nextLine 						; go to next line.
		#s_startLine 						; start of line.
		#s_get 								; get offset
		cmp 	#0					 		; if zero, fail.	
		beq 	_SSWFail 			
		#s_next 							; go to first character
		#s_next 							; (after all 3 s_next)
		;
		;			Go to next character, simple one.
		;
_SSWNextSimple:		
		#s_next
		;
_SSWLoop:
		#s_get 								; look at token.
		cmp 	#0 							; end of line ?
		beq 	_SSWNextLine 				; if so, then next line
		bpl 	_SSWNextSimple 				; needs to be a token, just skip char/number.
		;		
		ldx 	zTemp2 						; check structure count
		bne 	_SSWCheckUpDown 			; if it's non zero, then a match doesn't work.
		;
		cmp 	zTemp1 						; found the right keyword
		beq 	_SSWFound 					; so exit.
		;
_SSWCheckUpDown:
		cmp 	#firstKeywordPlus 			; if < keyword +
		bcc 	_SSWNext
		cmp 	#firstKeywordMinus 			; if < keyword - then as keyword +
		bcc 	_SSWPlus
		cmp 	#firstUnaryFunction			; if < first unary down as keyword -
		bcs 	_SSWNext 
		dec 	zTemp2 						; reduce structure count.
		dec 	zTemp2 						
_SSWPlus:
		inc 	zTemp2		
		bmi 	_SSWUnder					; error if driven -ve
_SSWNext:
		#s_skipelement 						; skip an element
		bra 	_SSWLoop 					
		;
_SSWFound:
		#s_next
		rts		
_SSWUnder:									; count has gone negative
		#Fatal	"Structure order"		
_SSWFail:									; couldn't find it.
		#Fatal	"Can't find structure"
