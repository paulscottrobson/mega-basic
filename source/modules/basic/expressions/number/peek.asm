; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		peek.asm
;		Purpose :	peek/deek/leek unary functions
;		Date :		22nd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Peek:	;; 	peek(
		lda 	#1 							; 1 byte
		bra 	UPMain

Unary_Deek:	;; 	deek(
		lda 	#2 							; 2 bytes
		bra 	UPMain

Unary_Leek:	;; 	leek(
		lda 	#4 							; 4 bytes

UPMain:	
		pha 								; save bytes to copy.
		;
		jsr 	EvaluateIntegerX 			; numeric parameter, the address to xEEK
		jsr 	CheckNextRParen 			; right bracket.
		;
		lda 	XS_Mantissa+0,x 			; copy the mantissa into ZLTemp1 (address)
		sta 	zLTemp1 
		lda 	XS_Mantissa+1,x
		sta 	zLTemp1+1		
		lda 	XS_Mantissa+2,x
		sta 	zLTemp1+2		
		lda 	XS_Mantissa+3,x
		sta 	zLTemp1+3	
		;
		lda 	#0 							; clear target area, which might get
		sta 	XS_Mantissa+0,x 			; 1,2 or 4 bytes.
		sta 	XS_Mantissa+1,x
		sta 	XS_Mantissa+2,x
		sta 	XS_Mantissa+3,x
		;
		pla 								; restore bytes to copy
		phx 								; save XY
		phy
		jsr 	MemRead 					; read the bytes in, processor dependent routine.
		ply 								; restore and exit
		plx
		rts
