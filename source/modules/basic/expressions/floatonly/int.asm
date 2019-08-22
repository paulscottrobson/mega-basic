; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		int.asm
;		Purpose :	int( unary function
;		Date :		22nd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Int: 	;; int(
		jsr 	EvaluateNumberX 			; get value
		jsr 	CheckNextRParen 			; check right bracket.
		jmp 	FPUToInteger				; Convert to integer.
		