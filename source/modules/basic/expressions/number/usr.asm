; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		usr.asm
;		Purpose :	Usr( unary function
;		Date :		22nd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Usr:	;; 	usr(
		jsr 	EvaluateNumberX 			; numeric parameter
		jsr 	CheckNextRParen 			; right bracket.
		phx 								; save XY
		phy
		nop
		.if 	cpu="65816"
		jsl 	UserVector
		.else
		jsr 	UserVector 					; call the USR function.
		.endif
		ply 								; and exit
		plx
		rts
;
USRDefault:
		#Fatal	"No USR vector."