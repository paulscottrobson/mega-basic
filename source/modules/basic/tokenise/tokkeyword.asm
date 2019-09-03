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
		tya 								; fix up genptr so Y = 0 access the current one.
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
;		token is at (zGenPtr)
;
; *******************************************************************************************

loadTokenChar:	.macro 							; load (keywordTable),y
		.if 	cpu=="65816"
		lda 	[zLTemp1],y
		.else
		lda 	(zLTemp1),y
		.endif
		.endm

TKWScanTokenTable:
		stx 	zLTemp1+1
		sta 	zLTemp1+0 						; store at zLTemp1
		;
		.if 	cpu=="65816" 					; yes, that problem again.
		lda 	#KeywordText >> 16 				; 24 bit addresses in the 65816
		sta 	zLTemp1+2 						; lovely.
		.endif
		;
		ldy 	#0 								; read and capitalise the first character
		sty 	zTemp2 							; zero the longest length match.
		lda 	(zGenPtr),y
		jsr 	TOKCapitalise 					; save this in zTemp3
		sta 	zTemp3
		lda 	#$80 							; current token in zTemp3+1
		sta 	zTemp3+1
		;
		;		Tokenising search loop.
		;
_TKWScanLoop:
		#loadTokenChar 							; get first character.
		and 	#$7F 							; drop bit 7, it might be 1 character long.
		cmp 	zTemp3 							; compare against got character.
		bne		_TKWNext 						; if it doesn't match, go to next.
		jsr 	_TKWClearY 						; make it so (zTemp1),y now points to zTemp1
		;
		;		Compare the token. 
		;
		ldy 	#0 								; compare the tokens directly
_TKWCompareFull:
		#loadTokenChar 							; get table char
		and 	#$7F 							; drop bit 7
		sta 	zTemp4
		lda 	(zGenPtr),y 					; compare against keyword in text.
		jsr 	TOKCapitalise 					; make it U/C
		cmp 	zTemp4 							; compare against table char w/o bit 7.
		bne 	_TKWNext 						; failed, go to next slot.
		#loadTokenChar							; get the token
		iny 									; bump pointer
		asl 	a 								; shift bit 7 into C
		bcc 	_TKWCompareFull					; keep going till that bit is 7 e.g. token matches
		;
		cpy 	zTemp2 							; compare against longest match
		bcc 	_TKWNext 						; if shorter, the original was better
		sty 	zTemp2							; update longest match.
		lda 	zTemp3+1 						; copy current token
		sta 	zTemp2+1 						; into matched token slot.		
		ldy 	#0 								; reset to start of matched token for forward		 	
		;
		;		Go to next slot.
		;
_TKWNext:				
		#loadTokenChar		 					; read character
		iny 									; next one.
		asl 	a 								; if bit 7 clear loop back.
		bcc 	_TKWNext 						
		inc 	zTemp3+1 						; increment current token.
		;
		;		This bit allows us to search using (xxx),y, but also use tables longer
		;		than 256 bytes. When y goes -ve, it is added to (zTemp1) and Y is reset.
		;
		tya 									; has Y gone negative.
		bpl 	_TKWNoYZero
		jsr 	_TKWClearY 						; make it so (zTemp1),y now points to zTemp1
_TKWNoYZero:
		#loadTokenChar							; if zero, we have reached the end of the table
		bne 	_TKWScanLoop 					; if not, try the next one.
		;		
		;		Check result and exit.
		;
		lda 	zTemp2 							; length of longest match
		beq 	_TKWFail 						; if zero, none found.
		tay 									; return the token in zTemp2, length => y
		lda 	zTemp2+1 						; so the offset is right.
		sec
		rts
		;
_TKWFail:		
		ldy 	#0 								; return with Y = 0 and carry clear.
		clc
		rts
;
;		Support function. Makes (zGenPtr) the same address as (zGenPtr),y and zeroes Y.
;
_TKWClearY:
		tya
		clc
		adc 	zLTemp1
		sta 	zLTemp1
		bcc 	_TKWCNoBump
		inc 	zLTemp1+1
_TKWCNoBump:
		ldy 	#0
		rts		