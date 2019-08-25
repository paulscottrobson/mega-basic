; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		evaluate.asm
;		Purpose :	Expression Evaluation.
;		Date :		20th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

VariableNameError:
		#Fatal 	"Bad Variable Name"

; *******************************************************************************************
;
;	A variable (A-Z followed by a sequence of A-Z0-9) is in the input stream. Read it in
;	apply the default type if necessary. Locate the variable/array, creating it if
; 	required, and set pointer and type variables appropriately.
;
; *******************************************************************************************

VariableFind:
		;
		;		Read the variable into the VarBuffer (same as NumBuffer)
		;
		phx 							; save X.
		lda 	#token_hashlParen  		; set the type to #( e.g. real array.
		sta 	Var_Type 
		sta 	Var_Hash 				; we initialise the hash with this. It doesn't matter
		;
		#s_get 							; get first character
		cmp 	#0 						; first one must be A-Z
		beq 	VariableNameError
		cmp 	#26+1
		bcs 	VariableNameError
		ldx 	#255 					; now copy it into the variable buffer.
_VFCopyBuffer:
		inx 							
		cpx 	#31 					; too long
		beq 	VariableNameError
		sta 	Var_Buffer,x 			; save character
		clc  							; update the hash value for it.
		adc 	Var_Hash
		sta 	Var_Hash
		#s_next 						; get the next character
		#s_get
		cmp 	#0 						; zero or token, end of variable
		beq 	_VFCopyEnd
		bmi 	_VFCopyEnd
		cmp 	#26+1 					; A-Z continue copying
		bcc 	_VFCopyBuffer
		cmp 	#"0" 					; 0-9 copy as well.
		bcc 	_VFCopyEnd
		cmp 	#"9"+1
		bcs 	_VFCopyBuffer
_VFCopyEnd:
		;
		;		This figures out which of the six types (int/float/str var or array)
		;		it is. xxx( maps to xxx#( and xxx to #. The default is set above.
		;
		#s_next 						; bump token pointer.
		cmp 	#token_Dollar 			; first type token.
		bcc 	_VFDefaultRequired 		
		cmp 	#token_PercentLParen+1	; last type token.
		bcc 	_VFHaveType
_VFDefaultRequired:		
		cmp 	#token_LParen 			; if it ends in ( then use the real array
		beq 	_VFSetType 				; default set above.
		dec 	Var_Type 				; this changes that default to the variable default
		#s_prev 						; undo the token bump.
_VFSetType:
		lda 	Var_Type 				; get type ....
_VFHaveType:
		;
		;		Store type and length, and set bit 7 of the last char of the name
		;	
		sta 	Var_Type 				; save as type.
		lda 	Var_Buffer,x 			; set bit 7 of name, marks the end.
		ora 	#$80
		sta 	Var_Buffer,x
		inx 							; offset 3 => length 4.
		stx 	Var_Length 				; save length of variable name.
		phy 							; Y and X now both saved on the stack.
		;
		;		Now figure out which hash link to use.
		;
		nop		


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