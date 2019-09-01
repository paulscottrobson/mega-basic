; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		wait.asm
;		Purpose :	Wait Command
;		Date :		29th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************
;
;				WAIT <address>,<and mask>[,<xor mask>]
;
;		Does (<address) & <and mask>) ^ <xor mask> until true.
;
Command_WAIT: 	;; wait

		jsr		EvaluateInteger 			; address
		;
		ldx 	#XS_Size 					; and mask.
		jsr 	CheckNextComma
		jsr 	EvaluateIntegerX
		;
		lda 	#0							; set default xor.
		sta 	XS_Mantissa+XS_Size*2
		;
		#s_get 								; comma follows ?
		cmp 	#token_Comma 				; no use the default
		bne 	_CWAXorDefault
		;
		#s_next 							; skip comma
		ldx 	#XS_Size*2
		jsr 	EvaluateIntegerX
		;
_CWAXorDefault:		
		lda 	XS_Mantissa 				; copy 24 bits of mantissa to ZLTemp1
		sta 	zLTemp1
		lda 	XS_Mantissa+1
		sta 	zLTemp1+1
		lda 	XS_Mantissa+2
		sta 	zLTemp1+2
		;
_CWAWaitLoop:
		jsr 	VIOCheckBreak 				; exit on break.
		cmp 	#0
		bne 	_CWAWaitExit
		lda 	#1							; read 1 byte to mantissa/0
		ldx 	#0		
		phy 								; this is the same routine as PEEK.
		jsr 	MemRead
		ply
		and 	XS_Mantissa+XS_Size 		; process it
		eor 	XS_Mantissa+XS_Size*2
		beq 	_CWAWaitLoop
_CWAWaitExit:		
		rts
