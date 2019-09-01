; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		branch.asm
;		Purpose :	GOTO, GOSUB, Return.
;		Date :		28th August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Command_GOTO: ;; GOTO
		jsr 	GotoGetLineNumber 			; get line number
CmdGOTO:		
		ldx 	#0 							; go to that line number
		jmp 	GotoChangeToLineNumberX



Command_GOSUB: ;; GOSUB
		jsr 	GotoGetLineNumber 			; get line number
CmdGOSUB:		
		jsr 	StackSavePosition 			; save position on stack and push frame
		lda 	#(SMark_Gosub << 4)+SourcePosSize
		jsr 	StackPushFrame
		ldx		#0 							; go to that line number
		jmp 	GotoChangeToLineNumberX


Command_RETURN: ;; RETURN
		lda 	#(SMark_Gosub << 4) 		; pop frame
		jsr 	StackPopFrame
		jsr 	StackRestorePosition 		; restore position.
		rts

; *******************************************************************************************
;
;										On GOTO/GOSUB
;
; *******************************************************************************************

Command_ON:		;; ON
		ldx 	#0 							; get the ON value into mantissa.0
		jsr 	SLIByteParameter
		lda 	XS_Mantissa+0 				; get the count
		beq 	_CONFail 					; can't be zero, error if it is.
		tax 								; save in X.
		;
		#s_get								; get and push next token		
		#s_next
		pha 								; so we can check what we're doing later.
		;
		cmp 	#token_GOTO 				; must be GOTO or GOSUB
		beq 	_CONOkayToken
		cmp 	#token_GOSUB
		beq 	_CONOkayToken
		jmp 	SyntaxError
		;
_CONOkayToken:
		phx 								; count on top, GOTO/GOSUB token 2nd.
_CONFindNumber:								
		jsr 	GotoGetLineNumber 			; get a line number.

		plx 								; restore count
		dex  								; decrement, exit if zero.
		beq 	_CONFound
		phx 								; push back

		jsr 	CheckNextComma				; check for comma
		bra 	_CONFindNumber 				; go round again.
		;
		;
_CONFound:
		pla 								; get token to decide what to do 
		cmp 	#token_GOTO 				; if GOTO				
		beq		CmdGOTO 					; then just branch.
		jsr 	SkipEndOfCommand 			; go to end of command
		bra 	CmdGOSUB 					; and do a GOSUB.

_CONFail:
		jmp 	BadParamError		

; *******************************************************************************************
;
;							Get line number in lowest mantissa element
;
; *******************************************************************************************

GotoGetLineNumber:
		jsr 	EvaluateInteger 			; get integer into mantissa.0
		lda 	XS_Mantissa+2 				; check range
		ora 	XS_Mantissa+3 				; check it is 0-32767
		bne 	_GLINError
		rts
_GLINError:
		#Fatal 	"Bad Line Number"		

; *******************************************************************************************
;
;						Transfer to line number in mantissa element X
;							  (no I'm not going to optimise it)
;
; *******************************************************************************************

GotoChangeToLineNumberX:
		lda 	XS_Mantissa+0,x 			; check line number not zero
		ora 	XS_Mantissa+1,x
		beq 	_GCTLFail 					; if so, no can do.
		;
		#s_toStart 							; back to start of program
_GCTLLoop:		
		#s_startLine 						; check offset = 0, if so fail as end of program
		#s_get								; so get the offset and check it
		cmp 	#0
		beq 	_GCTLFail
		;
		#s_next 							; compare LSB
		#s_get
		cmp 	XS_Mantissa+0,x
		bne 	_GCTLNext
		;
		#s_next 							; compare MSB
		#s_get
		cmp 	XS_Mantissa+1,x
		beq 	_GCTLExit
		;
		;		Go to next line, searching for the line number.
		;
_GCTLNext:
		#s_nextLine 						; try next line.
		bra 	_GCTLLoop 					; try next line.
_GCTLExit:
		#s_next 							; point to first token on new line.
		rts				

_GCTLFail:
		#Fatal 	"Bad Line Number"		
		