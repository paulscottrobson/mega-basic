; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		src_mega65.inc
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
		lda 	#2
		sta 	zCodePtr+2
		lda 	#0
		sta 	zCodePtr+3
		ldz 	#3
		.endm

; *******************************************************************************************
;
;						Forward and backward one code item, to start of line
;
; *******************************************************************************************

s_next:	.macro
		inz
		.endm

s_prev:	.macro
		dez
		.endm

s_start:.macro
		ldz 	#0
		.endm
		
; *******************************************************************************************
;
;								Get the next code item
;
; *******************************************************************************************

s_get:	.macro
		nop
		lda 	(zCodePtr),z
		.endm

; *******************************************************************************************
;
;								Compare the next code item
;
; *******************************************************************************************

s_cmp:	.macro
		nop
		cmp 	(zCodePtr),z
		.endm

; *******************************************************************************************
;
;								Move forward to next line.
;
; *******************************************************************************************

s_nextline: .macro
		ldz 	#0 							; point to offset
		nop
		lda 	(zCodePtr),z 				; read it
		clc
		adc 	zCodePtr 					; add to code pointer
		sta 	zCodePtr
		bcc 	_SNLNoCarry
		inc 	zCodePtr+1
_SNLNoCarry:
		.endm

; *******************************************************************************************
;
;								Advance one element
;
; *******************************************************************************************
		
s_skipelement: .macro
		nop
		lda 	(zCodePtr),z 				; read element
		inz 								; skip
		cmp 	#$F8 						; if < $F8 single character,token
		bcc 	_SEDone 					; so just skip over it.
		cmp 	#$FC 						; if < $FC double character token
		bcc 	_SEDouble
		tza 								; this is Y + 1
		clc
		nop
		adc 	(zCodePtr),z 				; add total length of element
		taz 								; back in Y.
		dez 								; fix up, one for the +1, one for the iny
		dez 
_SEDouble:
		inz
_SEDone:	
		.endm		

