; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		interface_test.asm
;		Purpose :	Assembler Interface Test
;		Date :		9th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

		* = $0000
		nop

		* = $A000

		.if 		INTERFACE=1
		.include 	"interface_emu.asm"
		.else
		.include 	"interface_mega65.asm"
		.endif
		.include 	"interface_tools.asm"

TestCode:
		ldx 		#$FF 					; empty stack
		txs
		jsr 		IF_Reset 				; reset external interface

		jsr 		IFT_ClearScreen
Next:	jsr 		IFT_NewLine
WaitKey:jsr 		IFT_ReadLine
		jsr 		IFT_NewLine
		ldx 		#0
_OutLine:
		lda 		$280,x
		beq 		Next
		jsr 		IFT_PrintCharacter
		lda 		#"_"
		jsr 		IFT_PrintCharacter
		inx
		bra 		_OutLine		

DummyRoutine:
		rti
		* = $FFFA
		.word		DummyRoutine
		.word 		TestCode
		.word 		DummyRoutine
