; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		input.asm
;		Purpose :	INPUT Command
;		Date :		1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Command_INPUT: ;; input
	
	lda 	#0 								; clear number of characters required.	
	sta 	InputAvailable 					; save character count
	sta 	InputRetry
	;
	;		Main input loop
	;
_CILoop:
	;
	;		Look for a prompt
	;
	#s_get 									; get the first character
	cmp 	#$FE 							; is it a prompt string
	bne 	_CINoPrompt
	;
	;		If found get its length and print it.
	;
	#s_next 								; get prompt length.
	#s_get 		
	tax 									; into X						
	#s_next
	dex 									; deduct marker/prompt length
	dex
	beq 	_CILoop 						; nothing.
_CIShowPrompt:
	#s_get 									; get and print prompt
	jsr 	VIOCharPrint
	#s_next
	dex
	bne 	_CIShowPrompt	
	bra 	_CILoop
	;
	;		Something there, it's not a quote mark. Skip over commas and semicolons
	;
_CIAdvance:
	#s_next	
_CINoPrompt:	
	#s_get
	cmp 	#token_Comma 					; skip , and ;
	beq 	_CIAdvance
	cmp 	#token_SemiColon
	beq 	_CIAdvance
	cmp 	#0 								; exit if 0 or :
	beq 	_CIExit 	
	cmp 	#token_Colon
	bne 	_CIIsVariable  					; if not then there#s a variable or should be !
_CIExit:
	rts
	;
	;		Variable found
	;	
_CIIsVariable:
	jsr 	VariableFind 					; set zVarType and zVarDataPtr accordingly.
	nop
	lda 	zVarType
	cmp 	#token_Dollar 					; is it a string ?
	beq 	_CIIsString
	;
	;		Float/Integer. Get text into NumBuffer. First skip spaces
	;
_CINGetText:	
	lda 	#0
	sta 	NumBufX
_CINSkip:
	jsr 	CIGetCharacter 					; get character skip spaces
	cmp 	#" "
	beq 	_CINSkip
	;
	;		Then copy number in till space, EOL or :
	;
_CINLoop: 									; get characters while continuous.
	ldx 	NumBufX 						; output character
	sta 	Num_Buffer,x
	lda 	#0 								; add trailing NULL
	sta 	Num_Buffer+1,x
	inc 	NumBufX 						; bump ptr
	jsr 	CIGetCharacter 					; get next character
	cmp 	#":"
	beq 	_CINCopied
	cmp 	#" "+1
	bcs 	_CINLoop
_CINCopied:	
	;
	;		Convert it to integer or float, and write it back.
	;
	ldx 	#0
	jsr 	ConvertNumBuffer 				; convert number
	jsr 	VariableSet 					; set variable.
	bra 	_CILoop 						; go round again. 	
	;
_CINFailed:
	lda 	#0 								; set to request input next time.
	sta 	InputAvailable
	bra 	_CINGetText 					; and try again	

_CIIsString:
	nop	

; *******************************************************************************************
;
;					Get character in A, return CR if no more characters.
;
; *******************************************************************************************

CIGetCharacter:
	nop