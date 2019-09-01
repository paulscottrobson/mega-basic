; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		get.asm
;		Purpose :	GET Command
;		Date :		1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************


Command_GET: 	;; get

_CGLoop:
		jsr 	VariableFind 				; get a variable.
		;
		jsr 	VIOCharGet 					; get character
		bcs 	_CGNoKey
		lda 	#0 							; if no character return zero
_CGNoKey:
		pha				
		;
		lda 	zVarType 					; look at the data type.
		cmp 	#token_Dollar 		
		beq 	_CGString
		;
		;		Return integer.
		;
		pla 								; put character in slot.
		sta 	XS_Mantissa
		lda 	#0
		sta 	XS_Mantissa+1
		sta 	XS_Mantissa+2
		sta 	XS_Mantissa+3
		lda 	#1 							; type integer
		sta 	XS_Type
		;
_CGWriteSetNext:		
		ldx 	#0 							; write number/WriteTempString out
		jsr 	VariableSet
		#s_get 								; look at next
		cmp 	#token_Comma 				; if not comma exit
		bne 	_CGExit
		#s_next 							; skip comma
		bra 	_CGLoop 					; and get another.
_CGExit:		
		rts
		;
		;		Return string.
		;
_CGString:
		lda 	#2 							; allocate temp string, space for 2.
		jsr 	AllocateTempString 			; initially empty.
		lda 	zTempStr 					; set up to be returned.
		sta 	XS_Mantissa
		lda 	zTempStr+1
		sta 	XS_Mantissa+1
		lda 	#2
		sta 	XS_Type

		pla 								; get A
		cmp 	#0
		beq 	_CGWriteSetNext
		jsr 	WriteTempString 			; write it into string
		bra 	_CGWriteSetNext

		