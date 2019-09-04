; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		macros32.inc
;		Purpose :	32 bit Macros (6502)
;		Date :		18th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

asl32 	.macro 								; asl32
		asl 	0+\1
		rol 	1+\1
		rol 	2+\1
		rol 	3+\1
		.endm		

asl32x 	.macro 								; asl32 \1,x
		asl 	0+\1,x
		rol 	1+\1,x
		rol 	2+\1,x
		rol 	3+\1,x
		.endm		

lsr32x 	.macro 								; lsr32 \1,x
		lsr 	3+\1,x
		ror 	2+\1,x
		ror 	1+\1,x
		ror 	0+\1,x
		.endm		

ror32x 	.macro 								; ror32 \1,x
		ror 	3+\1,x
		ror 	2+\1,x
		ror 	1+\1,x
		ror 	0+\1,x
		.endm		

ror32 	.macro 								; ror32 \1
		ror 	3+\1
		ror 	2+\1
		ror 	1+\1
		ror 	0+\1
		.endm		

add32x 	.macro 								; add \2 to \1
		clc
		lda 	\1+0,x
		adc 	\2+0,x
		sta 	\1+0,x
		lda 	\1+1,x
		adc 	\2+1,x
		sta 	\1+1,x
		lda 	\1+2,x
		adc 	\2+2,x
		sta 	\1+2,x
		lda 	\1+3,x
		adc 	\2+3,x
		sta 	\1+3,x
		.endm

sub32x 	.macro 								; subtract \2 from \1
		sec
		lda 	\1+0,x
		sbc 	\2+0,x
		sta 	\1+0,x
		lda 	\1+1,x
		sbc 	\2+1,x
		sta 	\1+1,x
		lda 	\1+2,x
		sbc 	\2+2,x
		sta 	\1+2,x
		lda 	\1+3,x
		sbc 	\2+3,x
		sta 	\1+3,x
		.endm

iszero32x .macro
		lda 	\1,x 						; check if \1 zero
		ora 	\1+1,x
		ora 	\1+2,x
		ora 	\1+3,x
		.endm

lsr32 	.macro 								; lsr32 \1
		lsr 	3+\1
		ror 	2+\1
		ror 	1+\1
		ror 	0+\1
		.endm		

