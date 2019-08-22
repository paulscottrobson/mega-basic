; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		em65816.asm
;		Purpose :	Code for 65816 emulator bootup etc.
;		Date :		18th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

		.cpu 		"65816"
		.as
		.xs

ResetStack: 	.macro
		rep 	#$30
		.al
		lda 	#$01FF 						; empty stack
		tcs
		.as
		.endm

Exit:	.macro
		.byte 	2
		.endm

HighMemory = $8000

		* = $1000
BasicProgram:		
		.include "../basic/testcode/testcode.src"
		* = $C000
		.include "../basic/header/header.src"

StartROM:
		clc
		xce	
		#ResetStack
		sep 	#$30 						; clear AXY in 16 bit.
		.al 	
		rep 	#$30
		lda 	#$0000
		tax
		tay
		.as
		sep 	#$30
		jsr 	IF_Reset 					; reset external interface
		jsr 	IFT_ClearScreen
		#Boot
