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

StartBasic:
		jsr 	IF_Reset 					; reset external interface
		jsr 	IFT_ClearScreen
;		jmp 	TIM_Start
		jsr 	FPTTest
		.byte 	$02
freeze:	bra 	freeze		

ERR_Handler:
		bra 	ERR_Handler

NMIHandler:
		rti

;		.include 	"testing/fptest.asm"	

		* = $FFFA
		.word	NMIHandler
		.word 	StartROM
		.word 	TIM_BreakVector
