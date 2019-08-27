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

		* = $8000

HighMemory = $7000
VariableMemory = $4000

BasicProgram:		
		.if loadTest = 0		
		.include "../basic/testcode/testcode.src"
		.endif
		.if loadTest = 1
		.include "../basic/testcode/testing.src"
		.endif
		.if loadTest = 2
		.include "../basic/testcode/testassign.src"
		.endif

		* = $A000

StartROM:
		#ResetStack
		jsr 	IF_Reset 					; reset external interface
		jsr 	IFT_ClearScreen
		#Boot


