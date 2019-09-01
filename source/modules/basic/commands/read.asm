; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		read.asm
;		Purpose :	READ/DATA/RESTORE Command
;		Date :		31st August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Command_READ:		;; read
		jsr 	VariableFind 				; get variable/value into zVarDataPtr,zVarType
		lda 	zVarDataPtr 				; save variable info on stack
		pha
		lda 	zVarDataPtr+1
		pha
		lda 	zVarType
		pha
		;
		jsr 	READGetDataItem 			; get the next data item
		;
		pla 								; restore target variable information.
		sta 	zVarType
		pla
		sta 	zVarDataPtr+1
		pla
		sta 	zVarDataPtr
		;
		ldx 	#0
		jsr 	VariableSet 				; set the value out.		
		;
		#s_get 								; look for comma
		#s_next
		cmp 	#token_Comma
		beq 	Command_READ 				; found, do another READ
		#s_prev 							; undo.
		rts

Command_DATA: 		;; data
		jmp 	SkipEndOfCommand

; *******************************************************************************************
;
;									RESTORE data pointer
;
; *******************************************************************************************

Command_RESTORE: 	;; restore
		pha
		lda 	#0 							; this being zero means 'initialise next read'					
		sta 	DataLPtr+0
		sta 	DataLPtr+1
		pla
		rts

; *******************************************************************************************
;
;								Swap the Code and Data pointers
;
; *******************************************************************************************

READSwapPointers:
		#s_offsetToA 						; current code offset
		pha 								; save it
		lda 	DataIndex 					; get data offset, and copy to offset		
		#s_AToOffset 				
		pla 								; get code offset and save in DataIndex
		sta 	DataIndex
		phx
		ldx 	#3 							; swap the Data Pointers (4 bytes) round.
_RSWLoop:
		lda 	DataLPtr+0,x
		pha
		lda 	zCodePtr+0,x
		sta 	DataLPtr+0,x		
		pla
		sta 	zCodePtr+0,x
		dex
		bpl 	_RSWLoop
		plx
		rts

; *******************************************************************************************
;
;							Get the next data item from code
;
; *******************************************************************************************

READGetDataItem:
		jsr 	ReadSwapPointers 			; swap code and data pointer.
		lda		zCodePtr+0 					; initialise ?
		ora 	zCodePtr+1 	
		bne 	_RGDIIsInitialised
		;
		#s_tostart 							; go to start
		bra 	_RGDIFindData 				; locate next data from start and read that.
		;
		;		If pointing at a comma, it was DATA xxx,yyy,zzz so can skip and fetch.
		;
_RGDIIsInitialised:
		#s_get 								; is there a comma, e.g. data continuation
		cmp 	#token_Comma
		beq 	_RGDISkipEvaluateExit 		
		;
		;		No data, so scan forward for next command till data/end.
		;
_RGDIFindData:
		#s_get 								; what's here.
		cmp 	#0 							; end of line
		beq 	_RGDIFindNextLine 
		cmp 	#token_DATA 				; found data token
		beq 	_RGDISkipEvaluateExit 		; then skip it and evaluate
		#s_skipelement		
		bra 	_RGDIFindData		
;
_RGDIFindNextLine:
		#s_nextLine 						; next line
		#s_startLine						; get offset to see if end.
		#s_get 								
		pha
		#s_next 							; to first token/character
		#s_next
		#s_next
		pla
		bne 	_RGDIFindData 				; back to scanning.
		jsr 	ReadSwapPointers 			; so we get error in line number of READ
		#Fatal	"Out of Data"				; nothing to evaluate

_RGDISkipEvaluateExit:
		#s_next 							; skip over , or DATA token.
		jsr 	EvaluateExpression 			; evaluate the expression
		jsr 	ReadSwapPointers 			; swap the pointers around.
		rts

