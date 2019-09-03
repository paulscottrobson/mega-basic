; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		usr.asm
;		Purpose :	Usr( unary function
;		Date :		22nd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Usr:	;; 	usr(
		jsr 	EvaluateNumberX 			; numeric parameter
		jsr 	CheckNextRParen 			; right bracket.
		;
		phx 								; save XY
		phy
		.if 	cpu=="65816" 				; call the USR vector short or long
		jsl 	UserVector 					; with the parameter in the base mantissa
		.else
		jsr 	UserVector 					; call the USR function.
		.endif
		ply 								; restore YX and exit with whatever the
		plx 								; routine called has chosen to do with it.
		rts
;
USRDefault:									; USR() vector is initialised to here.
		#Fatal	"No USR vector."