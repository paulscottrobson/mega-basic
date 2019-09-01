; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		pos.asm
;		Purpose :	Pos( unary function
;		Date :		31st August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Pos:	;; 	pos(		
		jsr 	EvaluateNumberX 			; get value, which is a dummy.
		jsr 	CheckNextRParen 			; check right bracket.
		jsr 	VIOCharGetPosition 			; get the position
		jmp		UnarySetAInteger			; and return that.

