; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		concrete.asm
;		Purpose :	Concrete string at mantissa.
;		Date :		25th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;					Concrete string in current Mantissa, return in AX
;
; *******************************************************************************************

StringConcrete:
		lda 	XS_Mantissa+0,x 			; save source to zTemp1
		sta 	zTemp1
		lda 	XS_Mantissa+1,x
		sta 	zTemp1+1
		;
		ldy 	#0 							; subtract the length+1 (clc) of the string.
		clc 								; from the string pointer
		lda 	StringPtr 					; and put in zTemp2 as well
		sbc 	(zTemp1),y
		sta 	StringPtr
		sta 	zTemp2
		;
		lda 	StringPtr+1
		sbc 	#0
		sta 	StringPtr+1
		sta 	zTemp2+1
		;
		lda 	(zTemp1),y 					; length add one for count
		inc 	a
		tax
_SCCopy:lda 	(zTemp1),y 					; copy whole thing including length
		sta 	(zTemp2),y
		iny
		dex
		bne 	_SCCopy
		;
		lda 	zTemp2+1 					; return concrete string in AX
		ldx 	zTemp2
		rts
