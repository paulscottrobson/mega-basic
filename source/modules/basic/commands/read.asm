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

READGetDataItem:
		lda 	#12
		sta 	XS_Mantissa+0
		lda 	#0
		sta 	XS_Mantissa+1
		sta 	XS_Mantissa+2
		sta 	XS_Mantissa+3
		lda 	#1
		sta 	XS_Type
		rts

