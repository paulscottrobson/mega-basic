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
	lda 	#0 								; this resets temporary string allocation.
	sta 	zTempStr+1 						; (could get lots of long strings)
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
	lda 	zVarType
	cmp 	#token_Dollar 					; is it a string ?
	beq 	_CIIsString
	;
	;		Float/Integer. Get text into NumBuffer. First skip spaces, commas
	;
_CINGetText:	
	lda 	#0
	sta 	NumBufX
_CINSkip:
	jsr 	CIGetCharacter 					; get character skip spaces
	cmp 	#" "
	beq 	_CINSkip
	cmp 	#","
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
	cmp 	#":" 							; stop on : ,
	beq 	_CINCopied
	cmp 	#","
	beq 	_CINCopied
	cmp 	#" "+1
	bcs 	_CINLoop
_CINCopied:	
	;
	;		Convert it to integer or float, and write it back.
	;
	ldx 	#0
	jsr 	ConvertNumBuffer 				; convert number
	bcs 	_CINFailed 						; didn't work.
	jsr 	VariableSet 					; set variable.
	bra 	_CILoop 						; go round again. 	
	;
_CINFailed:
	lda 	#0 								; set to request input next time.
	sta 	InputAvailable
	bra 	_CINGetText 					; and try again	
	;
	;		Handle string . Quoted string or terminated with : or <CR>
	;		Uses tokenising buffer.
	;
_CIIsString:
	nop	

; *******************************************************************************************
;
;					Get character in A, return CR if no more characters.
;							 (this is for keyboard input only)
;
; *******************************************************************************************

CIGetCharacter:
	phy
	ldy		InputAvailable 					; anything available
	beq 	_CIGCNewLine 					; no, needs a new line.
	lda 	IFT_LineBuffer,y 				; read line buffer entry
	cmp 	#13 							; got 13 ?
	beq 	_CIGCNoInc
	inc 	InputAvailable 					; if not, advance character pointer.
_CIGCNoInc:
	ply
	rts	

_CIGCNewLine:
	inc 	InputAvailable 					; next pointer to 1 (first char this time)
	lda 	#"?"
	jsr 	VIOCharPrint
	ldy 	InputRetry 						; retry flag set
	beq 	_CIGCPrompt 					; if so, then print ? again
	jsr 	VIOCharPrint
_CIGCPrompt:	
	ldy 	#1
	sty 	InputRetry 						; set the input retry flag to non-zero
_CIGCBackOne:	
	dey
_CIGCLoop:
	cpy 	#80 							; stop overflow.
	beq 	_CIGCBackOne
	jsr 	VIOCharGet 						; get a character
	beq 	_CIGCLoop 						; wait until key pressed
	cmp 	#8 								; backspace
	beq 	_CIGCBackSpace
	jsr 	VIOCharPrint 					; echo character
	sta		IFT_LineBuffer,y 				; write into buffer and bump
	iny
	cmp 	#13 							; until CR pressed.
	bne 	_CIGCLoop 	
	lda 	IFT_LineBuffer 					; return first char in buffer
	ply 									; restore Y
	rts
;
_CIGCBackSpace:
	cpy 	#0 								; can only B/S if not first 
	beq 	_CIGCLoop
	jsr 	VIOCharPrint 					; echo BS
	dey 									; go back one.
	bra 	_CIGCLoop	

		