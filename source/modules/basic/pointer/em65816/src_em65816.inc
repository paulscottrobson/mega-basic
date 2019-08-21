; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		src_em65816.inc
;		Purpose :	Source code address manipulation.
;		Date :		19th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;				Go back to the start - points to the first code item.
;
; *******************************************************************************************

s_toStart:	.macro
		lda 	#BasicProgram & $FF
		sta 	zCodePtr+0
		lda 	#BasicProgram >> 8
		sta 	zCodePtr+1
		lda 	#0
		sta 	zCodePtr+2
		sta 	zCodePtr+3
		ldy 	#3
		.endm

; *******************************************************************************************
;
;							Forward and backward one code item
;
; *******************************************************************************************

s_next:	.macro
		iny
		.endm

s_prev:	.macro
		dey
		.endm

; *******************************************************************************************
;
;								Get the next code item
;
; *******************************************************************************************

s_get:	.macro
		lda 	(zCodePtr),y		
		.endm
