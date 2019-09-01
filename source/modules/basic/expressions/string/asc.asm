; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		asc.asm
;		Purpose :	return ASCII value of the first character.
;		Date :		22nd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Asc: 	;;	asc(
		jsr 	EvaluateStringX 			; string parameter
		jsr 	CheckNextRParen 			; right bracket.
		;
		phy 								; get the string length
		ldy 	#0
		lda 	(zGenPtr),y
		beq 	_UAIllegal 					; must be at least one character, 0 => error
		iny
		lda 	(zGenPtr),y 				; read the first character
		ply
		jmp 	UnarySetAInteger 			; return that as an integer 0-255.
_UAIllegal:
		jmp 	BadParamError

		
				