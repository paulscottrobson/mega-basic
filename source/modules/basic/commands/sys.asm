; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		sys.asm
;		Purpose :	SYS Command
;		Date :		29th August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Command_SYS: 	;; sys
		jsr 	EvaluateInteger 			; address to call.
		;
		lda 	XS_Mantissa+0				; copy to localvector
		sta 	LocalVector+0 				; only three, can only do 24 bit calls
		lda 	XS_Mantissa+1 				; and that only on 65816
		sta 	LocalVector+1
		lda 	XS_Mantissa+2
		sta 	LocalVector+2
		;
		.if cpu="65816" 					; call the routine using long or short 
		jsl 	_CSYLocalCall 				; jump depending on 24/16 bit code address
		.else
		jsr 	_CSYLocalCall
		.endif
		rts

_CSYLocalCall:
		.if cpu="65816"						; long or short jump dependent on code
		jmp 	[LocalVector]		 		; address
		.else
		jmp 	(LocalVector)				
		.endif
		