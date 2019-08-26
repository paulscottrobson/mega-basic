; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		variables.asm
;		Purpose :	Variable handling code.
;		Date :		20th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;							Process a variable reference in code.
;
; *******************************************************************************************

VariableFind:
		jsr 	VariableExtract 		; find out all about it ....
		;
		jsr 	VariableLocate 			; does it already exist ?
		bcs 	_VFExists 				; if so, use that.
		jsr 	VariableCreate 			; otherwise create it.
_VFExists:
		;
		;		TODO: Array look up, if appropriate :)
		;
		rts

; *******************************************************************************************
;
;									Clear the variables
;
; *******************************************************************************************

VariableClear:
		pha 							; save registers
		phx
		ldx 	#0 						; clear out the hash table.
		txa
_VCLoop:sta 	HashTableBase,x
		inx
		cpx 	#HashTableEnd-HashTableBase
		bne 	_VCLoop
		;
		lda 	#VariableMemory & $FF	; reset the free variable memory pointer
		sta 	VarMemPtr
		lda 	#VariableMemory >> 8
		sta 	VarMemPtr+1
		;
		plx 							; restore registers		
		pla 			
		rts

; *******************************************************************************************
;
;		Variable Record
;
;		+0,+1 		Link to next variable
;		+2 			Hash of this variable.
;		+3 			First char of name (6 bit)
;		+4 			Second char of name
;		+x 			Last char of name, has bit 7 set.
;		+x+1 		Data (2, 4 or 5 bytes)
;					Pointer to array structure.
;
;		Array Record
;
;		+0,+1 		Number of array elements. Bit 7 set if this is a pointer not data
;					(e.g. they are sub levels)
;		+2 			Pointer array for sub levels
;					Data array for data levels
;	
; *******************************************************************************************
