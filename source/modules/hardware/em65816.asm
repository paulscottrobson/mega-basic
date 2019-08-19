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

		* = $C000
		#HeadTables

StartROM:
		clc
		xce	
		#ResetStack
		sep 	#$30
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
