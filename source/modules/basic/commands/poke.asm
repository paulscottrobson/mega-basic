; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		poke.asm
;		Purpose :	POKE,DOKE and LOKE Command
;		Date :		29th August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Command_POKE: 	;; poke
		lda 	#1 							; 1 byte
		bra 	CmdPoke_Main

Command_DOKE: 	;; doke
		lda 	#2 							; 2 bytes
		bra 	CmdPoke_Main

Command_LOKE: 	;; loke
		lda 	#4							; 4 bytes

;
;		Shared routine. On entry A is the bytes to copy in the "Poke"
;
CmdPoke_Main:
		pha
		jsr 	EvaluateInteger 			; get two parameters. First is address
		inx6
		jsr 	CheckNextComma
		jsr 	EvaluateIntegerX 			; second is the data.
		;
		lda 	XS_Mantissa+0 				; copy the mantissa into ZLTemp1 (address)
		sta 	zLTemp1
		lda 	XS_Mantissa+1
		sta 	zLTemp1+1		
		lda 	XS_Mantissa+2
		sta 	zLTemp1+2		
		lda 	XS_Mantissa+3
		sta 	zLTemp1+3	
		;
		pla 								; get count
		phy 								; save Y
		jsr 	MemWrite 					; write it out
		ply 								; restore Y and done.

		rts

		