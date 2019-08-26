; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		arrayidx.asm
;		Purpose :	Array Indexing
;		Date :		26th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;		On entry, Mantissa,X contains the index, and zVarDataPtr is the address of
;		the next array level.
;
; *******************************************************************************************

ArrayIndexFollow:
		phy 	
		;
		;		Find the start of the array.
		;
		ldy 	#0 							; make zVarDataPtr point to the array.
		lda 	(zVarDataPtr),y 			; e.g. it points to itself.
		pha
		iny
		lda 	(zVarDataPtr),y
		sta 	zVarDataPtr+1
		pla
		sta 	zVarDataPtr
		;
		;		Validate the array index 
		;
		lda 	XS_Mantissa+1,x 			; MSB of 16 bit integer and bytes 2&3
		and 	#$80 						; must be zero.
		ora 	XS_Mantissa+2,x 			
		ora 	XS_Mantissa+3,x
		bne 	_AIFError
		;
		;		Against the size.
		;
		ldy 	#0 							; calculate size - current - 1
		clc
		lda 	(zVarDataPtr),y
		sbc 	XS_Mantissa+0,x
		iny
		lda 	(zVarDataPtr),y
		php 								; clear bit 7 retaining borrow.
		and 	#$7F
		plp
		sbc 	XS_Mantissa+1,x
		bcc 	_AIFError 					; eror if size-current < 0
		;		
		;		Convert the mantissa to an offset. Use zTemp1
		;

		lda  	XS_Mantissa+0,x 			; copy and double the index
		asl 	a 							; (e.g. index * 2)
		sta 	zTemp1
		lda 	XS_Mantissa+1,x 			
		rol 	a
		sta 	zTemp1+1
		;
		ldy 	#1 							; is this a data entry.
		lda 	(zVarDataPtr),y 			; if so, then type is unchanged, offset set
		bmi 	_AIFCalculate
		;
		dec 	zVarType 					; converts from an array to a type.
		;
		lda 	zVarType 					; check that type
		cmp 	#token_Dollar 				; if string, use x 2
		beq 	_AIFCalculate
		;
		asl 	zTemp1			 			; double the index
		rol 	zTemp1+1					; (e.g. index * 4)
		cmp 	#token_Percent 				; if integer, use x 4
		beq 	_AIFCalculate
		;
		clc 								; add the original mantissa in again
		lda 	XS_Mantissa+0,x 			; which makes it x5, for float.
		adc 	zTemp1
		sta 	zTemp1
		lda 	XS_Mantissa+1,x
		adc 	zTemp1+1
		sta 	zTemp1+1
		;
		;		Add mantissa + 2 to zVarDataPtr, so it points to the pointer,
		;		or the data accordingly.
		;
_AIFCalculate:
		clc 								; add index x 2,4 or 5 to base
		lda 	zVarDataPtr
		adc 	zTemp1
		sta 	zVarDataPtr
		lda 	zVarDataPtr+1
		adc 	zTemp1+1
		sta 	zVarDataPtr+1
		;
		clc 								; add 2 more for the length prefix.
		lda 	zVarDataPtr
		adc 	#2
		sta 	zVarDataPtr
		bcc 	_AIFNoBump
		inc 	zVarDataPtr+1
_AIFNoBump:
		ply
		rts

_AIFError:
		#Fatal	"Bad array index"
