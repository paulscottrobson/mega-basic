; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		len.asm
;		Purpose :	String length function.
;		Date :		22nd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Len: 	;;	len(
		jsr 	EvaluateStringX 			; string parameter
		jsr 	CheckNextRParen 			; right bracket.
		;
		;
		;
		phy 								; get the string length
		ldy 	#0
		lda 	(zGenPtr),y
		ply
		jmp 	UnarySetAInteger 			; return as an integer.

		

