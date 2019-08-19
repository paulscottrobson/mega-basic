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

		* = $A000	 						; cannot start $C000-$E000 because of the mapping.

ResetStack: 	.macro
		ldx 		#$FF 					; empty stack
		txs
		.endm

Exit:	.macro
_halt:	bra 		_halt
		.endm

StartROM:
		#ResetStack
		jsr 	IF_Reset 					; reset external interface
		jsr 	IFT_ClearScreen
		#Boot


