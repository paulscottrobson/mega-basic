; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		basic.asm
;		Purpose :	Basic Main Program
;		Date :		18th August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

		.include "_include.asm"				; include generated modules file.

		#Exit

		* = $FFF8
DefaultInterrupt:		
		rti
		* = $FFFA
		#nmihandler 						; NMI vector
		.word 	StartROM 					; Reset vector
		#irqhandler 						; IRQ Vector
