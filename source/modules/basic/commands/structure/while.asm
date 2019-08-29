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
		jsr 	StructureSearchSingle
		#s_next 							; skip over the token.
		rts

Command_WEND: ;; wend
		lda 	#(SMark_While << 4)			; remove the frame
		jsr 	StackPopFrame
		jsr 	StackRestorePosition 		
		bra 	Command_WHILE 				; and do the while again.
		rts

