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
		jmp 	GotoChangeToLineNumber

Command_GOSUB: ;; GOSUB
		jsr 	GotoGetLineNumber
		jsr 	StackSavePosition
		lda 	#(SMark_Gosub << 4)+SourcePosSize
		jsr 	StackPushFrame
		jmp 	GotoChangeToLineNumber

Command_RETURN: ;; RETURN
		lda 	#(SMark_Gosub << 4)
		jsr 	StackPopFrame
		jsr 	StackRestorePosition
		rts

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
;						Transfer to line number in lowest mantissa element
;
; *******************************************************************************************

GotoChangeToLineNumber:
		lda 	XS_Mantissa+0 				; check line number not zero
		ora 	XS_Mantissa+1
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
		cmp 	XS_Mantissa+0
		bne 	_GCTLNext
		#s_next 							; compare MSB
		#s_get
		cmp 	XS_Mantissa+1
		beq 	_GCTLExit
_GCTLNext:
		#s_nextLine 						; try next line.
		bra 	_GCTLLoop 					; try next line.
_GCTLExit:
		#s_next 							; point to first token.
		rts				

_GCTLFail:
		#Fatal 	"Bad Line Number"		