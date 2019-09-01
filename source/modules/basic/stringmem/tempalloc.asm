; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		tempalloc.asm
;		Purpose :	Allocate temporary string space.
;		Date :		22nd August 2019
;		Review : 	1st September 2019
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
		;		Initialise temporary string pointer 256 bytes below the string 
		;		area, so there's always space to concrete one string.
		;
		lda 	StringPtr 					; set temporary string ptr 1 page below available
		sta 	zTempStr					; space, this is for strings to be concreted.
		lda 	StringPtr+1 	
		dec 	a 							; allow the page.
		sta 	zTempStr+1
		;
_ATSInitialised:
		pla 								; get required count back.
		eor 	#$FF 						; negate and add 2's complement.
		inc 	a
		;
		clc
		adc 	zTempStr 					; "add" to the temp string pointer
		sta 	zTempStr					; which means the tsp is also the current.
		lda 	#$FF
		adc 	zTempStr+1
		sta 	zTempStr+1
		;
		lda 	#0 							; clear temp string by zeroing length.
		phy
		tay
		sta 	(zTempStr),y
		ply
		inc 	a 							; reset the write index to 1 (first character)
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
		#s_get 								; this is the length + 2 value
		;
		dec 	a 							; we need one more than actual length for temp str
		jsr 	AllocateTempString 			; allocate memory for temporary string.
		;
		#s_get 								; the length + 2, again.
		#s_next 							; go to next character, e.g. the first in string
		;
		dec 	a 							; make the actual length in characters, allowing
		dec 	a 							; for the marker and the length.

		ldx 	#0 							; set that as the length of the string.
		sta 	(zTempStr,x)

		sta 	zLTemp1 					; that's used as a count.
		ora 	#0 							; if zero already, exit
		beq 	_CTSCExit
		;
_CTSCLoop:
		#s_get 								; get the next character
		#s_next 							; skip it
		phy 								; save Y

		inx 								; bump index
		phx 								; save that
		ply 								; index into Y
		sta 	(zTempStr),y 				; save at index position

		ply 								; restore Y
		dec 	zLTemp1 					; do for each character, this is the counter.
		bne 	_CTSCLoop
;
_CTSCExit:
		plx 								; restore X
		rts 								; exit

