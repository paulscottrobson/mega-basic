; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		core.asm
;		Purpose :	Basic Main Core
;		Date :		19th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

BASIC_Start:
		jsr 	ResetRunStatus 				; clear everything (CLR command)
		lda 	#0 							; mark temp string pointer uninitialised.
		sta 	zTempStr+1 					; (done before every base level evaluation/or command)

		#s_toStart
		#s_next
		#s_get
		jsr 	EvaluateExpression
		
		#Exit

SyntaxError:
ERR_Handler:
		bra 	ERR_Handler

