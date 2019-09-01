; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		6502.asm
;		Purpose :	Memory access (Peek/Poke) for 6502
;		Date :		23rd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;						Copy A bytes from (ZLTemp1) into Mantissa
;
; *******************************************************************************************

MemRead:
		sta 	SignCount 					; save count
		ldy 	#0 							; start from here
_MLoop1:lda 	(zlTemp1),y 				; read the long address
		sta 	XS_Mantissa,x 				; copy into mantissa
		iny 								; next to copy		
		inx
		cpy 	SignCount 					; do required # of bytes.
		bne 	_MLoop1
		rts

; *******************************************************************************************
;
;						Copy A bytes from Mantissa into (ZLTemp1)
;
; *******************************************************************************************

MemWrite:
		sta 	SignCount 					; save count
		ldy 	#0 							; start from here
_MLoop1:lda 	XS_Mantissa,x 				; read mantisssa
		sta 	(zlTemp1),y 				; write it out
		iny 								; next to copy		
		inx
		cpy 	SignCount 					; do required # of bytes.
		bne 	_MLoop1
		rts				