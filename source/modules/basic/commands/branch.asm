; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		branch.asm
;		Purpose :	GOTO, GOSUB, Return.
;		Date :		28th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Command_GOTO: ;; GOTO
		jsr 	GotoGetLineNumber
CmdGOTO:		
		ldx 	#0
		jmp 	GotoChangeToLineNumberX

Command_GOSUB: ;; GOSUB
		jsr 	GotoGetLineNumber
CmdGOSUB:		
		jsr 	StackSavePosition
		lda 	#(SMark_Gosub << 4)+SourcePosSize
		jsr 	StackPushFrame
		ldx		#0
		jmp 	GotoChangeToLineNumberX

Command_RETURN: ;; RETURN
		lda 	#(SMark_Gosub << 4)
		jsr 	StackPopFrame
		jsr 	StackRestorePosition
		rts

; *******************************************************************************************
;
;										On GOTO/GOSUB
;
; *******************************************************************************************

Command_ON:		;; ON
		ldx 	#0 							; get the ON.
		jsr 	SLIByteParameter
		lda 	XS_Mantissa+0 				; get the count
		beq 	_CONFail 					; can't be zero.
		tax 								; save in X.
		;
		#s_get								; get and push next token		
		#s_next
		pha
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
		bra 	_CONFindNumber
		;
		;
_CONFound:
		pla 								; get token
		cmp 	#token_GOTO 				; if GOTO				
		beq		CmdGOTO 					; then just branch.
		;
		;		Go to end of line before GOSUB.
		;
_CONEndOfCmd:
		#s_get 								; get next token
		cmp 	#0 							; if zero, end of line, so exit
		beq 	CMDGosub
		cmp 	#token_Colon 				; if colon, end of command
		beq 	CMDGosub
		#s_skipElement 						; go forward
		bra 	_CONEndOfCmd

_CONFail:
		jmp 	BadParamError		

; *******************************************************************************************
;
;							Get line number in lowest mantissa element
;
; *******************************************************************************************

GotoGetLineNumber:
		jsr 	EvaluateInteger
		lda 	XS_Mantissa+2 				; check range
		ora 	XS_Mantissa+3
		bne 	_GLINError
		rts
_GLINError:
		#Fatal 	"Bad Line Number"		

; *******************************************************************************************
;
;						Transfer to line number in mantissa element X
;
; *******************************************************************************************

GotoChangeToLineNumberX:
		lda 	XS_Mantissa+0,x 			; check line number not zero
		ora 	XS_Mantissa+1,x
		beq 	_GCTLFail
		;
		#s_toStart 							; back to start of program
_GCTLLoop:		
		#s_startLine 						; check offset = 0, if so fail.
		#s_get
		cmp 	#0
		beq 	_GCTLFail
		#s_next 							; compare LSB
		#s_get
		cmp 	XS_Mantissa+0,x
		bne 	_GCTLNext
		#s_next 							; compare MSB
		#s_get
		cmp 	XS_Mantissa+1,x
		beq 	_GCTLExit
_GCTLNext:
		#s_nextLine 						; try next line.
		bra 	_GCTLLoop 					; try next line.
_GCTLExit:
		#s_next 							; point to first token.
		rts				

_GCTLFail:
		#Fatal 	"Bad Line Number"		