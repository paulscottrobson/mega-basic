; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		chr.asm
;		Purpose :	String from ASCII value.
;		Date :		22nd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Chr: 	;;	chr$(
		jsr 	EvaluateIntegerX			; numeric parameter
		jsr 	CheckNextRParen 			; right bracket.
		;
		lda 	XS_Mantissa+1,x 			; check upper bytes 0
		ora 	XS_Mantissa+2,x
		ora 	XS_Mantissa+3,x
		bne 	_UCChar
		;
		lda 	#1 							; one character string
		jsr 	AllocateTempString		
		lda 	XS_Mantissa+0,x 			; get char# and write it.
		jsr 	WriteTempString
		jmp 	UnaryReturnTempStr
_UCChar:
		#Fatal	"Bad character code"

