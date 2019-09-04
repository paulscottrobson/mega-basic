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
VariableMemory = 0
BasicProgram = $2000

		* = $8000

BasicProgramStart:		
		.if loadTest == 1		
		.include "../basic/testcode/testcode.src"
		.endif
		.if loadTest == 2
		.include "../basic/testcode/testing.src"
		.endif
		.if loadTest ==	3
		.include "../basic/testcode/testassign.src"
		.endif
BasicProgramEnd:

		* = $A000

StartROM:
		#ResetStack
		jsr 	IF_Reset 					; reset external interface
		jsr 	IFT_ClearScreen
		.if 	loadTest != 0
		jsr 	CopyProgram
		.endif
		#Boot

;
;		When testing the program is stored in ROM between $8000 and $9FFF
;		This copies it into the relevant workspace.
;
		.if 	loadTest != 0
CopyProgram:
		lda 	#BasicProgramStart & $FF
		sta 	zLTemp1+0
		lda 	#(BasicProgramStart >> 8) & $FF
		sta 	zLTemp1+1
		lda 	#2
		sta 	zLTemp1+2
		lda 	#0
		sta 	zLTemp1+3
		;
		lda 	#BasicProgram & $FF
		sta 	zTemp1
		lda 	#BasicProgram >> 8
		sta 	zTemp1+1
		ldz 	#0
		ldy 	#0
_Copy1:	nop	
		lda 	(zLTemp1),z
		sta 	(zTemp1),y
		iny
		inz
		bne 	_Copy1
		inc 	zLTemp1+1
		inc 	zTemp1+1
		lda 	zLTemp1+1
		cmp 	#(BasicProgramEnd >> 8) & $FF
		bcc 	_Copy1
		beq 	_Copy1
		rts
		.endif