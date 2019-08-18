; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		basic.asm
;		Purpose :	Basic Main Program
;		Date :		18th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************


		.include "_include.asm"				; include generated modules file.

		#Exit

ERR_Handler:
		bra 	ERR_Handler


		* = $FFF8
DefaultInterrupt:		
		rti
		* = $FFFA
		#nmihandler
		.word 	StartROM
		#irqhandler
