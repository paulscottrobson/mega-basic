; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		varcreate.asm
;		Purpose :	Create variable whose description is in the variable slot.
;		Date :		20th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;								Create variable
;
; *******************************************************************************************

VariableCreate:
		phx
		phy

		lda 	VarMemPtr 					; get address of next free into zTemp1
		sta 	zTemp1
		lda 	VarMemPtr+1
		sta 	zTemp1+1
		;
		lda 	Var_DataSize 				; bytes for the data bit
		clc
		adc 	Var_Length 					; add the length of the name
		adc 	#3 							; 3 for the link and the hash.
		;
		adc 	VarMemPtr 					; add to variable memory pointer
		sta 	VarMemPtr
		bcc 	_VCNoCarry
		inc 	VarMemPtr+1
_VCNoCarry:		
		;
		lda 	Var_HashAddress 			; hash table pointer in zTemp2
		sta 	zTemp2
		lda 	#HashTableBase >> 8
		sta 	zTemp2+1
		;
		ldy 	#0 							; put current hash link in position.
		lda 	(zTemp2),y
		sta 	(zTemp1),y
		iny
		lda 	(zTemp2),y
		sta 	(zTemp1),y
		iny
		;
		lda 	Var_Hash 					; write the hash out.
		sta 	(zTemp1),y
		iny
		;
		ldx 	#0 							; copy the name out.
_VCCopyName:		
		lda 	Var_Buffer,x
		sta 	(zTemp1),y
		inx
		iny
		cpx 	Var_Length
		bne 	_VCCopyName 
		;
		phy 								; save the data offset.
		ldx 	Var_DataSize 				; and write the data out.
		lda 	#0 							; which is all zeroes.
_VCClearData:
		sta 	(zTemp1),y
		iny
		dex
		bne 	_VCClearData
		;
		pla 								; offset to the data
		clc
		adc 	zTemp1 						; add to start and save as data pointer.
		sta 	zVarDataPtr 				
		lda 	zTemp1+1
		adc 	#0
		sta 	zVarDataPtr+1
		;
		lda 	Var_Type 					; and set the type.
		sta 	zVarType
		;
		lda 	zTemp1 						; fix hash link to point to new record
		ldy 	#0
		sta 	(zTemp2),y
		iny
		lda 	zTemp1+1
		sta 	(zTemp2),y

		ply
		plx
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
; *******************************************************************************************