; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		tokkeyword.asm
;		Purpose :	Tokenise ASCII string into keyword
;		Date :		2nd September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;					Tokenise ASCIIZ string at (zGenPtr),y to a keyword
;					If matches, write to buffer and return CS, otherwise CC
;
; *******************************************************************************************

TokeniseKeyword:
		tya 								; fix up genptr so Y = 0
		clc
		adc 	zGenPtr 					
		sta 	zGenPtr
		bcc 	_TKWNoBump
		inc 	zGenPtr+1
_TKWNoBump:
		ldy 	#0 							; this adds Y to genPtr, so it will still scan
		;
		;		Scan first standard table (codes $80-$F7)
		;
		phx
		lda 	#KeyWordText & $FF 			; scan this table.
		ldx 	#(KeyWordText >> 8) & $FF
		jsr 	TKWScanTokenTable
		plx
		bcc 	_TKWNoWrite		
		sta 	TokeniseBuffer,x 			; write the token out.
		inx
_TKWNoWrite:		
		rts

; *******************************************************************************************
;
;		Scan token table at XA. If true, return token # in A, and CS, else return CC.
;
; *******************************************************************************************

TKWScanTokenTable:
		clc
		rts
