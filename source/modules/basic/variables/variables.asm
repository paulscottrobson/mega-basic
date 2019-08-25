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
