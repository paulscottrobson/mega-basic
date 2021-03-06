; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		repeat.asm
;		Purpose :	REPEAT/UNTIL
;		Date :		28th August 2019
;		Review : 	1st September 2019;		
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Command_REPEAT: ;; REPEAT
		jsr 	StackSavePosition			; save position into stack
		lda 	#(SMark_Repeat << 4)+SourcePosSize
		jsr 	StackPushFrame 				; push on stack
		rts


Command_UNTIL: ;; UNTIL
		lda 	#(SMark_Repeat << 4)		; remove the frame, checking it.
		jsr 	StackPopFrame
		jsr 	EvaluateInteger				; work out the UNTIL expression.
		;
		lda 	XS_Mantissa+0 				; check if zero.
		ora 	XS_Mantissa+1
		ora 	XS_Mantissa+2
		ora 	XS_Mantissa+3
		bne 	_CUTExit 					; if not, just exit
		;
		jsr 	StackRestorePosition 		; otherwise loop round again.
		lda 	#(SMark_Repeat << 4)+SourcePosSize
		jsr 	StackPushFrame 				; fix the stack back so we can pop it again.
_CUTExit:		
		rts

