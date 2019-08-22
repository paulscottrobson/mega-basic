; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		asc.asm
;		Purpose :	ASCII value first character.
;		Date :		22nd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Asc: 	;;	asc(
		jsr 	EvaluateStringX 			; string parameter
		jsr 	CheckNextRParen 			; right bracket.
		phy 								; get the string length
		ldy 	#0
		lda 	(zGenPtr),y
		beq 	_UAIllegal 					; must be at least one character
		iny
		lda 	(zGenPtr),y 				; read it.
		ply
		jmp 	UnarySetAInteger
_UAIllegal:
		#Fatal	"Illegal Quantity"
