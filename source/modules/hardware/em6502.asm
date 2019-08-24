; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		em6502.asm
;		Purpose :	Code for 6502 general start up
;		Date :		18th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

		.cpu 		"65c02"
		
ResetStack: 	.macro
		ldx 		#$FF 					; empty stack
		txs
		.endm

HighMemory = $8000

		* = $1000
BasicProgram:
		.if loadTest = 0		
		.include "../basic/testcode/testcode.src"
		.else
		.include "../basic/testcode/testing.src"
		.endif
		* = $C000
		.include "../basic/header/header.src"

StartROM:
		#ResetStack
		jsr 	IF_Reset 					; reset external interface
		jsr 	IFT_ClearScreen
		#Boot

