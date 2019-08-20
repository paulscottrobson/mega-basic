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


StartROM:
		#ResetStack
		jsr 	IF_Reset 					; reset external interface
		jsr 	IFT_ClearScreen
		#Boot



		* = $1000
BasicProgram:		
		#DemoProgram

		* = $C000
		#HeadTables

