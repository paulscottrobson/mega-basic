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
		lda 	#$4C 						; JMP opcode
		sta 	LocalVector
		sta 	UserVector
		lda 	#USRDefault & $FF 			; reset USR vector
		sta 	UserVector+1
		lda 	#(USRDefault >> 8) & $FF
		sta 	UserVector+2		
		;
		jsr 	ResetRunStatus 				; clear everything (CLR command)
		;
		; TODO: NEW, maybe.
		;
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

