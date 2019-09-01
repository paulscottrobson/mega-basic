; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		wait.asm
;		Purpose :	Wait Command
;		Date :		29th August 2019
;		Review : 	1st September 2019
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
		jsr		EvaluateInteger 			; get address to monitor
		;
		ldx 	#XS_Size 					; get and mask 
		jsr 	CheckNextComma
		jsr 	EvaluateIntegerX
		;
		lda 	#0							; set default xor value.
		sta 	XS_Mantissa+XS_Size*2
		;
		#s_get 								; comma follows ?
		cmp 	#token_Comma 				; no use the default
		bne 	_CWAXorDefault
		;
		#s_next 							; skip comma
		ldx 	#XS_Size*2					; and get the xor value
		jsr 	EvaluateIntegerX
		;
		;		All three values set up.
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
		;
		lda 	#1							; read 1 byte to mantissa/0
		ldx 	#0		
		phy 								; this is the same routine as PEEK.
		jsr 	MemRead
		ply
		;
		lda 	XS_Mantissa+0 				; get byte
		and 	XS_Mantissa+XS_Size 		; and it
		eor 	XS_Mantissa+XS_Size*2		; eor it.
		beq 	_CWAWaitLoop 				; and loop if zero.
_CWAWaitExit:		
		rts
