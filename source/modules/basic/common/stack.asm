; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		stack.asm
;		Purpose :	Stack Handler.
;		Date :		23rd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************
;
;		zBasicSP points to TOS, which is two four bit fields. 
;			Bits 7..4 	specify the 'thing stacked'
;			Bits 3..0 	specify the depth of the stack entry.
;
;		the stack top is marked by $00, because there has to be at least one entry
;		in each stack frame.
;
; *******************************************************************************************
;
;									Stack Reset
;
; *******************************************************************************************

StackReset:
		pha
		phy
		lda 	#(BasicStack & $FF) 		; reset pointer
		sta 	zBasicSP
		lda 	#(BasicStack >> 8)
		sta 	zBasicSP+1
		ldy 	#0 							; reset stack top to $00 which cannot
		tya 								; be a legal token.
		sta 	(zBasicSP),y 	
		ply
		pla
		rts

; *******************************************************************************************
;
;			Add a new frame, of type A (4 bit type,4 bit size) onto the stack.
;
; *******************************************************************************************

StackPushFrame:
		pha
		phy
		inc 	a 							; one extra byte in frame, for the marker.
		pha 								; save it.
		and 	#$0F 						; lower 4 bits
		clc 								; add to Basic Stack
		adc 	zBasicSP 					
		sta 	zBasicSP
		bcc 	_SPFNoBump
		inc 	zBasicSP+1
_SPFNoBump: 								; put the frame marker on the top of the stack
		ldy 	#0 							
		pla
		sta 	(zBasicSP),y		
		ply
		pla
		rts

; *******************************************************************************************
;
;			Pop Frame. Type marker required in A (4 bit type, 4 bit doesn't matter)
;
; *******************************************************************************************

StackPopFrame:
		pha
		phy
		ldy 	#0 							; compare with top of stack using EOR
		eor 	(zBasicSP),y
		and 	#$F0 						; top 4 bits zero, match
		bne 	_SPFError 					; mixed structures 	
		;
		lda 	(zBasicSP),y 				; get size from byte
		and 	#$0F
		eor 	#$FF						; 2's complement
		sec
		adc 	zBasicSP
		sta 	zBasicSP
		bcs 	_SPFNoBump
		dec 	zBasicSP+1
_SPFNoBump:
		ply
		pla		
		rts

_SPFError:
		#Fatal	"Mixed Structures"		

; *******************************************************************************************
;
;					Put current position in source on stack, at offset 1
;
; *******************************************************************************************

StackSavePosition:
		#s_OffsetToA 						; get the position
		phy
		ldy 	#5
		sta 	(zBasicSP),y

		ldy 	#1
		lda 	zCodePtr+0 					; 4 bytes, could reduce this for 65816/6502
		sta 	(zBasicSP),y
		iny
		lda 	zCodePtr+1
		sta 	(zBasicSP),y
		iny
		lda 	zCodePtr+2
		sta 	(zBasicSP),y
		iny
		lda 	zCodePtr+3
		sta 	(zBasicSP),y

		ply		
		rts

; *******************************************************************************************
;
;					Restore current position off stack, from offset 1.
;
; *******************************************************************************************

StackRestorePosition:
		phy
		ldy 	#1 							; copy 4 bytes that are the pointer
		lda 	(zBasicSP),y
		sta 	zCodePtr+0
		iny
		lda 	(zBasicSP),y
		sta 	zCodePtr+1
		iny
		lda 	(zBasicSP),y
		sta 	zCodePtr+2
		iny
		lda 	(zBasicSP),y
		sta 	zCodePtr+3
		iny
		lda 	(zBasicSP),y 				; offset
		ply 								; restore Y
		#s_AToOffset 						; set up the offset.
		rts
