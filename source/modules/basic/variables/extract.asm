; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		extract.asm
;		Purpose :	Extract a name, hash and type and hash table link address
;		Date :		25th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

VariableNameError:
		#Fatal 	"Bad Variable Name"

; *******************************************************************************************
;
;	A variable (A-Z followed by a sequence of A-Z0-9) is in the input stream. Read it in
;	apply the default type if necessary. Save the hash value, the type and the name.
;
; *******************************************************************************************

VariableExtract:
		phx 							; save X.		
		;
		;		Set the default type if none is specified.
		;
		.if hasFloat == 1
		lda 	#token_hashlParen  		; set the type to #( e.g. real array.
		.else
		lda 	#token_percentlParen 	; no floats, use integer.
		.endif
		sta 	Var_Type 

		sta 	Var_Hash 				; we initialise the hash with this. It doesn't matter
		;
		;
		;		Read the variable into the VarBuffer (same as NumBuffer)
		;
		#s_get 							; get first character
		cmp 	#0 						; first one must be A-Z
		beq 	VariableNameError
		cmp 	#26+1
		bcs 	VariableNameError
		ldx 	#255 					; now copy it into the variable buffer.
_VECopyBuffer:
		inx 							
		cpx 	#31 					; too long
		beq 	VariableNameError
		sta 	Var_Buffer,x 			; save character
		clc  							; update the hash value for it.
		adc 	Var_Hash
		;
		; 		lda 	#0 				; this disables the hashing for testing.
		;
		sta 	Var_Hash
		#s_next 						; get the next character
		#s_get
		cmp 	#0 						; zero or token, end of variable
		beq 	_VECopyEnd
		bmi 	_VECopyEnd
		cmp 	#26+1 					; A-Z continue copying
		bcc 	_VECopyBuffer
		cmp 	#"0" 					; 0-9 copy as well.
		bcc 	_VECopyEnd
		cmp 	#"9"+1
		bcc 	_VECopyBuffer
_VECopyEnd:
		;
		;		This figures out which of the six types (int/float/str var or array)
		;		it is. xxx( maps to xxx#( and xxx to #. The default is set above.
		;
		#s_next 						; bump token pointer.
		cmp 	#token_Dollar 			; first type token.
		bcc 	_VEDefaultRequired 		
		cmp 	#token_PercentLParen+1	; last type token.
		bcc 	_VEHaveType
_VEDefaultRequired:		
		cmp 	#token_LParen 			; if it ends in ( then use the real array
		beq 	_VESetType 				; default set above.
		dec 	Var_Type 				; this changes that default to the variable default
		#s_prev 						; undo the token bump.
_VESetType:
		lda 	Var_Type 				; get type ....
_VEHaveType:
		;
		;		Store type and length, and set bit 7 of the last char of the name
		;
		sta 	Var_Type 				; save as type.
		lda 	Var_Buffer,x 			; set bit 7 of name, marks the end.
		ora 	#$80
		sta 	Var_Buffer,x
		inx 							; offset 3 => length 4.
		stx 	Var_Length 				; save length of variable name.
		;
		;		Now figure out which hash link to use.
		;
		lda 	Var_Type 				; get offset of var type from first type token
		sec 
		sbc 	#token_Dollar 			
		asl 	a 						; multiply by 16. This requires HashTableSize
		asl 	a 						; in data.asm to be 8 (8 sets of links,2 bytes each)
		asl 	a
		asl 	a 
		sta 	Var_HashAddress
		;
		lda 	Var_Hash 				; get the hash
		and 	#(HashTableSize-1) 		; force into range 0-tableSize-1
		asl 	a 						; double it (2 bytes per entry) & clears carry
		adc 	Var_HashAddress 		; add table offset.
		adc 	#HashTableBase & $FF 	; now the low byte of the actual table address
		sta 	Var_HashAddress 		
		;
		;		Finally work out the data size.
		;
		ldx 	#5 						; hash is 5 bytes (real)
		lda 	Var_Type
		cmp 	#token_Hash
		beq 	_VEHaveSize
		dex 
		cmp 	#token_Percent 			; percent is 4 bytes (integer)
		beq 	_VEHaveSize
		ldx 	#2 						; everything else is two.
_VEHaveSize:
		stx 	Var_DataSize		
		plx
		rts
		