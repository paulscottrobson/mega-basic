; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		handlers.inc
;		Purpose :	Decision tree for various combinations of int and float.
;		Date :		21st August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

inx6 	.macro 								; add 6 to x
		inx
		inx
		inx
		inx
		inx
		inx
		.endm

; *******************************************************************************************
;
;									Have Float *and* Integer
;
; *******************************************************************************************

		.if 	hasFloat!=0 && hasInteger!=0
BinaryChoose:	.macro 						; <float code>,<integer code>
		lda 	XS_Type,x 					; and 2 type bytes together.
		and 	XS2_Type,x
		lsr 	a 							; shift bit 0 into C
		bcc 	_BCFloat 					; if zero, they aren't both integer, so do it as float
		jmp 	\2 							; so execute code at \1
_BCFloat:
		jsr 	BinaryMakeBothFloat 		; validate they are floats, make them both float.
		jmp 	\1 							; and execute code at \2
		.endm
		.endif

		.if 	hasFloat==0 && hasInteger!=0
BinaryChoose:	.macro 						; <float code>,<integer code>
		jmp 	\2 							; so execute code at \1
		.endm
		.endif
