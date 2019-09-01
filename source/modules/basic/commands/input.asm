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



_CIIsString:
	nop	