; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		print.asm
;		Purpose :	PRINT Command
;		Date :		24th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************


Command_PRINT: 	;; print
		#s_get 								; semicolon, skip, get next.
		cmp 	#0 							; end
		beq 	_CPR_NewLine
		cmp 	#token_Colon
		beq 	_CPR_NewLine
		cmp 	#token_SemiColon
		beq 	_CPR_Skip
		cmp 	#token_Comma
		beq 	_CPR_Tab
		jsr 	EvaluateExpression 			; get expression.
		lda 	XS_Type 					; get type.
		and 	#2
		bne 	_CPR_String 				; if type = 2 output as string.
		;
		;		Output number
		;
_CPR_Number:
		lda 	#0 							; reset buffer index
		sta 	NumBufX
		lda 	XS_Type 					; get type
		lsr 	a
		bcs 	_CPRInt 					; if msb set do as integer
		.if 	hasFloat=1 
		jsr 	FPToString 					; call fp to str otherwise
		.fi
		bra 	_CPRNPrint
_CPRInt:jsr 	IntToString		
_CPRNPrint:
		lda 	Num_Buffer 					; is first character -
		cmp 	#"-"
		beq 	_CPRNoSpace
		lda 	#" "						; print the leading space
		jsr 	CharPrint 					; so beloved of MS Basics.
_CPRNoSpace:		
		ldx 	#(Num_Buffer-1) & $FF
		lda 	#(Num_Buffer-1) >> 8
		bra 	_CPRPrint
		;
		;		Output a string
		;
_CPR_String:
		ldx 	XS_Mantissa
		lda 	XS_Mantissa+1
		;
		;		Output text at AX (count-prefixed)
		;
_CPRPrint:
		stx 	zGenPtr
		sta 	zGenPtr+1
		phy
		ldy 	#0							; get length into X	
		lda 	(zGenPtr),y
		tax
		beq 	_CPREndPrint 				; nothing to print
_CPRLoop:
		iny
		lda 	(zGenPtr),y
		jsr 	CharPrint
		dex
		bne 	_CPRLoop
_CPREndPrint:
		ply		
		bra 	Command_Print		
		;
		;		Output a tab
		;		
_CPR_Tab:
		jsr 	IFT_Tab
		;
		;		Skip current, check end.
		;		
_CPR_Skip:
		#s_next 							; skip semicolon/comma
		#s_get 								; get next
		cmp 	#token_Colon 				; colon or $00, exit
		beq 	_CPR_Exit
		cmp 	#0
		bne 	Command_PRINT 				; if not go round again.
		bra 	_CPR_Exit
		;
		;		CR and exit		
		;
_CPR_NewLine:
		jsr 	IFT_NewLine		
_CPR_Exit:
		rts				






		