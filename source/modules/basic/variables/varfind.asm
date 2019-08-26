; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		varfind.asm
;		Purpose :	Examine current hash table chain for a variable.
;		Date :		20th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;		Locate variable in hash table chain. CC if failed, CS and pointers set up if
;		succeeded.
;
; *******************************************************************************************

VariableLocate:
		phx
		phy
		lda 	Var_HashAddress 			; hash table pointer in zTemp2
		sta 	zTemp2 						; points to first address.
		lda 	#HashTableBase >> 8
		sta 	zTemp2+1
		;
_VLNext:ldy 	#0 							; get next link into AX
		lda 	(zTemp2),y
		tax
		iny
		lda 	(zTemp2),y
		;
		sta 	zTemp2+1 					; save in zTemp
		stx 	zTemp2 
		;
		ora 	zTemp2 						; got zero
		clc
		beq 	_VLExit 					; if so, then fail as end of chain.
		;
		iny 								; point to hash (offset + 2)
		lda 	(zTemp2),y
		cmp 	Var_Hash
		bne 	_VLNext 					; try next if different.
		;
_VLCompare:
		iny 								; next character
		lda 	(zTemp2),y 					; compare variable field against buffer.
		cmp 	Var_Buffer-3,y 				; the -3 is because name starts at 3.
		bne 	_VLNext 					; fail if different, try next.
		asl 	a 							; until end character (bit 7 set) matched
		bcc 	_VLCompare
		;
		tya 
		sec 								; add 1 as Y points to last character
		adc 	zTemp2 						; add to the current address
		sta 	zVarDataPtr
		lda 	zTemp2+1
		adc 	#0
		sta 	zVarDataPtr+1
		;
		lda 	Var_Type 					; and set the type.
		sta 	zVarType
		;		
		sec 								; return CS
_VLExit:ply
		plx	
		rts