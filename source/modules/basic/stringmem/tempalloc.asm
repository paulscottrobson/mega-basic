; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		tempalloc.asm
;		Purpose :	Allocate temporary string space.
;		Date :		22nd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;					Allocate A bytes of memory for temporary string.
;									(Result in zTempStr)
;
; *******************************************************************************************

AllocateTempString:
		pha 								; save required count.
		lda 	zTempStr+1 					; check if initialised yet ?
		bne 	_ATSInitialised
		;
		lda 	StringPtr 					; set temporary string ptr 1 page below available
		sta 	zTempStr					; space, this is for strings to be concreted.
		lda 	StringPtr+1
		dec 	a
		sta 	zTempStr+1
		;
_ATSInitialised:
		pla 								; get required count back.
		eor 	#$FF 						; negate 2's complement.
		inc 	a
		;
		clc
		adc 	zTempStr 					; "add" to the temp string pointer
		sta 	zTempStr		
		lda 	#$FF
		adc 	zTempStr+1
		sta 	zTempStr+1
		;
		lda 	#0 							; clear temp string.
		phy
		tay
		sta 	(zTempStr),y
		ply
		inc 	a 							; reset the write index.
		sta 	TempStringWriteIndex
		rts

; *******************************************************************************************
;
;						Write character to current temporary string
;
; *******************************************************************************************

WriteTempString:
		phy 								; save Y
		ldy 	TempStringWriteIndex	 	; write position.
		sta 	(zTempStr),y 				; write character out.
		inc 	TempStringWriteIndex 		; increment the write position.
		tya 								; unchanged Y is now length
		ldy 	#0
		sta 	(zTempStr),y
		ply 								; restore Y and exit
		rts

; *******************************************************************************************
;
;					Copy string from source (length+2) to string memory
;
; *******************************************************************************************

CreateTempStringCopy:
		phx 								; save X
		#s_get 								; this is the length + 2
		dec 	a 							; we need one more than actual length for temp str
		jsr 	AllocateTempString 			; allocate memory for temporary string.
		;
		#s_get 								; the length + 2, again.
		#s_next 							; go to next character/
		dec 	a 							; make the actual length in charactes
		dec 	a 		
		ldx 	#0 							; set that as the length of the string.
		sta 	(zTempStr,x)
		sta 	zLTemp1 					; that's used as a count.
		ora 	#0 							; if zero already, exit
		beq 	_CTSCExit
		;
_CTSCLoop:
		#s_get 								; get the next character
		#s_next 							; skip it
		phy 								; save in Y
		inx 								; bump index
		txy 								; index into Y
		sta 	(zTempStr),y 				; save at index
		ply 								; restore Y
		dec 	zLTemp1 					; do for each character
		bne 	_CTSCLoop
;
_CTSCExit:
		plx 								; restore X
		rts 								; exit
