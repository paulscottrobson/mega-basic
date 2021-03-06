; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		chr.asm
;		Purpose :	String from ASCII value.
;		Date :		22nd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Chr: 	;;	chr$(
		jsr 	EvaluateIntegerX			; numeric parameter which is the character we want
		jsr 	CheckNextRParen 			; right bracket.
		;
		lda 	XS_Mantissa+1,x 			; check upper bytes 0
		ora 	XS_Mantissa+2,x
		ora 	XS_Mantissa+3,x
		bne 	_UCChar
		;
		lda 	#1+1 						; one character string. 2 bytes - size+char
		jsr 	AllocateTempString			; allocate it.
		lda 	XS_Mantissa+0,x 			; get char# and write it.
		jsr 	WriteTempString
		jmp 	UnaryReturnTempStr 			; and return that string.
		;
_UCChar:
		jmp 	BadParamError

