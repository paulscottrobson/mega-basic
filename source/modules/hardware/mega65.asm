; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		mega65.asm
;		Purpose :	Code for 4510 general start up
;		Date :		18th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

		.cpu 		"4510"

ResetStack: 	.macro
		ldx 		#$FF 					; empty stack
		txs
		.endm

Exit:	.macro
_halt:	bra 		_halt
		.endm

		* = $1000
BasicProgram:		
		.include "../basic/testcode/testcode.src"
		* = $A000
		.include "../common/header/header.src"

StartROM:
		#ResetStack
		jsr 	IF_Reset 					; reset external interface
		jsr 	IFT_ClearScreen
		#Boot


