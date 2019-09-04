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
		lda 	#$0000 						; make sure A zero.
		sep 	#$30 						
		.as
		.endm

Exit:	.macro
		.byte 	2
		.endm

HighMemory = $7F00
VariableMemory = 0
	
		* = $1000
BasicProgram:		
		.if loadTest == 1		
		.include "../basic/testcode/testcode.src"
		.endif
		.if loadTest == 2
		.include "../basic/testcode/testing.src"
		.endif
		.if loadTest == 3
		.include "../basic/testcode/testassign.src"
		.endif

		* = $C000
StartROM:
		clc
		xce	
		#ResetStack
		rep 	#$30						; clear AXY in 16 bit.
		lda 	#$0000
		tax
		tay
		.as
		sep 	#$30
		#Boot

TIM_BreakHandler:
		jmp 	TIM_BreakVector

		* = $18000

