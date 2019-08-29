; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		sys.asm
;		Purpose :	SYS Command
;		Date :		29th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Command_SYS: 	;; sys
		jsr 	EvaluateInteger 			; address
		;
		lda 	XS_Mantissa+0				; copy to localvector
		sta 	LocalVector+0 				; only three, can only do 24 bit calls
		lda 	XS_Mantissa+1 				; and that only on 65816
		sta 	LocalVector+1
		lda 	XS_Mantissa+2
		sta 	LocalVector+2
		;
		.if cpu="65816"
		jsl 	_CSYLocalCall
		.else
		jsr 	_CSYLocalCall
		.endif
		rts

_CSYLocalCall:
		.if cpu="65816"
		jmp 	[LocalVector]		
		.else
		jmp 	(LocalVector)				
		.endif
		