; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fptest.asm
;		Purpose :	Runs floating point script code, used in testing.
;					(not normally included in the binary)
;		Date :		18th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

check:	.macro								; binary operators, except Compare which returns
		cmp 	#\1 						; the -1/0/1 value in AC.
		bne 	_skip1
		jsr 	FPT_Preamble
		jsr 	\2
		jsr 	FPT_Postamble
		bra 	FPTLoop
_skip1:
		.endm

; *******************************************************************************************
;
;								Do the arithmetic tests
;
; *******************************************************************************************

FPTTest:
		lda 	#FPTTestData & $FF 			; set zGenPtr to data.
		sta 	zGenPtr
		lda 	#FPTTestData >> 8
		sta 	zGenPtr+1
		ldx 	#0 							; start at stack bottom.
FPTLoop:lda 	zGenPtr+1
		jsr 	TIM_WriteHex
		lda 	zGenPtr
		jsr 	TIM_WriteHex
		lda 	#"."
		jsr		IFT_PrintCharacter
		jsr 	FPTGet 						; get next command
		cmp 	#0 							; zero, exit
		beq 	FPTExit
		cmp 	#1 							; 1,load
		beq 	FPTLoad
		#check 	"+",FPAdd 					; binary operations.
		#check 	"-",FPSubtract
		#check 	"*",FPMultiply
		#check 	"/",FPDivide
		cmp 	#"~" 						; ~, compare
		beq 	FPTCompare
		cmp 	#"="						; = check equal
		beq 	FPTCheck
FPTError:
		bra 	FPTError
		;
		;		1 loads integer/float value in.
		;
FPTLoad:
		ldy 	#6 							; data to copy
_FPTLoadLoop:
		jsr 	FPTGet
		sta 	XS_Mantissa,x
		inx
		dey
		bne 	_FPTLoadLoop
		bra 	FPTLoop
		;	
		;		0 which is stop (XEmu, Hardware) exit (emulator)
		;
FPTExit:		
		lda 	#42
		jsr 	IFT_PrintCharacter
		rts
		;
		;		~ Compare top two values
		;
FPTCompare:
		jsr 	FPT_Preamble
		jsr 	FPCompare
		jsr 	FPUSetInteger
		jsr 	FPUToFloat
		jsr 	FPT_Postamble
		jmp 	FPTLoop		
		;
		;		= Check top two values equal, stop if not, throw away TOS.
		;
FPTCheck:		
		jsr 	FPT_Preamble
		jsr 	FPCompare
		ora 	#0
_FPTCFail:		
		bne 	_FPTCFail
		jmp 	FPTLoop		
		;
		;		Before calling FP calculation, do this
		;
FPT_Preamble:
		txa
		sec
		sbc 	#12
		tax
		rts
		;
		;		After calling FP calculation , do this.
		;
FPT_Postamble:
		txa
		clc
		adc 	#6
		tax
		rts

; *******************************************************************************************
;
;			Get a single character
;
; *******************************************************************************************

FPTGet:	phy
		ldy 	#0
		lda 	(zGenPtr),y
		pha
		inc 	zGenPtr
		bne 	_FPTGet1
		inc 	zGenPtr+1
_FPTGet1:
		pla
		ply
		rts		

; *******************************************************************************************
;
;				Included test data created in floating-point directory.
;
; *******************************************************************************************

FPTTestData:
		.include "script.inc"
		.byte 	0		

