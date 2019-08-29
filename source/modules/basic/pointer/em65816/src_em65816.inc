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
;						Forward and backward one code item, to start of line
;
; *******************************************************************************************

s_next:	.macro
		iny
		.endm

s_prev:	.macro
		dey
		.endm

s_startLine:.macro
		ldy 	#0
		.endm

; *******************************************************************************************
;
;								 Position to/from A
;
; *******************************************************************************************
		
s_offsetToA: .macro		
		tya
		.endm

s_AToOffset: .macro		
		tay
		.endm

; *******************************************************************************************
;
;								Get/Set the next code item
;
; *******************************************************************************************

s_get:	.macro
		lda 	[zCodePtr],y		
		.endm

s_put:	.macro
		sta 	[zCodePtr],y		
		.endm

; *******************************************************************************************
;
;								Compare the next code item
;
; *******************************************************************************************

s_cmp:	.macro
		cmp 	[zCodePtr],y		
		.endm

; *******************************************************************************************
;
;								Move forward to next line.
;
; *******************************************************************************************

s_nextline: .macro
		ldy 	#0 							; point to offset
		lda 	[zCodePtr],y 				; read it
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
		lda 	[zCodePtr],y 				; read element
		iny 								; skip
		cmp 	#$F8 						; if < $F8 single character,token
		bcc 	_SEDone 					; so just skip over it.
		cmp 	#$FC 						; if < $FC double character token
		bcc 	_SEDouble
		tya 								; this is Y + 1
		clc
		adc 	[zCodePtr],y 				; add total length of element
		tay 								; back in Y.
		dey 								; fix up, one for the +1, one for the iny
		dey 
_SEDouble:
		iny
_SEDone:	
		.endm		

