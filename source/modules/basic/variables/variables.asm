; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		variables.asm
;		Purpose :	Expression Evaluation.
;		Date :		20th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;		Process a variable reference in code.
;
; *******************************************************************************************

VariableFind:
		jsr 	VariableExtract 		; find out all about it ....

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
		plx 							; restore registers
		pla 			
		rts

VariableGet:
		nop