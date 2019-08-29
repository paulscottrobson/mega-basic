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

HighMemory = $7F00
VariableMemory = $2000

		* = $8000

BasicProgram:		
		.if loadTest = 1		
		.include "../basic/testcode/testcode.src"
		.endif
		.if loadTest = 2
		.include "../basic/testcode/testing.src"
		.endif
		.if loadTest = 3
		.include "../basic/testcode/testassign.src"
		.endif

		* = $A000

StartROM:
		#ResetStack
		jsr 	IF_Reset 					; reset external interface
		jsr 	IFT_ClearScreen
		#Boot


