; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		4510.asm
;		Purpose :	Memory access (Peek/Poke) for 4510
;		Date :		23rd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;						Copy A bytes from ZLTemp1 into Mantissa
;
; *******************************************************************************************

MemRead:phz
		sta 	SignCount 					; save count
		ldz 	#0 							; start from here
_MLoop1:nop
		lda 	(zlTemp1),z 				; read the long address
		sta 	XS_Mantissa,x 				; copy into mantissa
		inz 								; next to copy		
		inx
		cpz 	SignCount 					; do required # of bytes.
		bne 	_MLoop1
		plz
		rts