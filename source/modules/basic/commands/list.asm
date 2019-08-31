; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		list.asm
;		Purpose :	LIST Command
;		Date :		29th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************


Command_LIST: 	;; list
		jsr 	ListGetRange				; get any parameters
		#s_toStart 							; start of program
		lda 	#0 							; reset the indent
		sta 	ListIndent
_CILLoop:
		#s_startLine 						; start of line
		#s_get 								; read offset
		cmp 	#0 							; if zero, end of program
		beq 	_CILExit
		jsr 	CheckBreak 					; check break
		cmp 	#0		
		bne 	_CILExit
		jsr 	ListCheckRange 				; check current line in range.
		bcs		_CILNext

		#s_startLine 						; move to start
		#s_next
		#s_next
		#s_next
		;
		jsr 	ListLine 					; list one line.
		;
_CILNext:		
		#s_nextline 						; go to next
		bra 	_CILLoop						
_CILExit:
		jmp 	WarmStart

; *******************************************************************************************
;
;										List current line
;
; *******************************************************************************************

ListLine:
		#s_startLine 						; get line# into low 1st mantissa
		#s_next
		#s_get
		sta 	XS_Mantissa
		#s_next
		#s_get
		sta 	XS_Mantissa+1
		jsr 	Print16BitInteger 			; print integer.
		sec
		sbc 	ListIndent 					; subtract indent e.g. print more.
		tax 								; print spaces to column 6
_LISpace:
		lda 	#" "
		jsr 	ListPrintLC
		inx
		cpx 	#6
		bne 	_LISpace		
;
;		Main decode loop
;
_LIDecode:
		#s_next 							; next character
		#s_get
		cmp 	#0 							; zero, exit.
		beq 	_LIExit
		bmi 	_LIToken
		cmp 	#$40 						; 01-$3F, character.
		bcs 	_LIInteger
		eor 	#$20 						; make 7 bit		
		adc 	#$20
		jsr 	ListPrintLC 				; print in LC
		bra 	_LIDecode
_LIExit:		
		lda 	#13 						; print new line.
		jmp 	ListPrintLC
;
;		Handle $FC-$FF (strings, remarks, decimals.)
;		
_LIToken:
		cmp 	#$FC 						; $FC-$FF ?
		bcc		_LICommandToken
		;
		pha 								; save in case end
		ldx 	#'"'						; print if $FE quoted string
		cmp 	#$FE
		beq 	_LIPrint
		ldx 	#'.'						; print if $FD decimals
		cmp 	#$FD
		beq 	_LIPrint
		lda 	#'R'						; must be REM
		jsr 	ListPrintLC
		lda 	#'E'
		jsr 	ListPrintLC
		lda 	#'M'
		jsr 	ListPrintLC
		ldx 	#' '
_LIPrint:		
		txa
		jsr 	ListPrintLC
		#s_next 							; length (overall, e.g. +2)
		#s_get
		tax 								; put in X
		dex
_LILoop:
		dex 								; exit when count reached zero.
		beq 	_LIEnd				
		#s_next 							; get and print
		#s_get
		jsr 	ListPrintLC
		bra 	_LILoop
;
_LIEnd:	pla 								; get A back
		cmp 	#$FE 						; if '"' need closing quotes
		bne 	_LIDecode
		lda 	#'"'
		jsr 	ListPrintLC
		bra 	_LIDecode
;
_LIInteger:
		ldx 	#0
		jsr 	EvaluateGetInteger 			; get an atom 
		#s_prev 							; because we pre-increment on the loop
		jsr 	Print32BitInteger 			; print integer.
		bra 	_LIDecode				
;
;		Handle a command token. This only handles 80-FF tokens, so needs extending
; 		for shifts. Change initial value for shifts
;
_LICommandToken:
		phy 								; save Y
		pha 								; save token
		ldx  	#KeywordText & $FF 			; address of keyword text table.
		lda 	(#KeywordText >> 8) & $FF
		stx 	zLTemp1
		sta 	zLTemp1+1
		lda 	(#KeywordText >> 16) & $FF 	; this is for 65816 (it's a table in code
		sta 	zLTemp1+2 					; space) and won't affect a 6502 at all.
		;
		pla 								; get token
		and 	#127 						; chuck bit 7.
		beq 	_LIFoundToken
		tax
_LITokenLoop: 								; if alpha token, then print space if
		ldy 	#0 							; last character not a token.
_LIFindEnd:
		.if 	cpu="65816"					; find end next token
		lda 	[zLTemp1],y
		.else
		lda 	(zLTemp1),y 		
		.endif
		iny
		asl 	a
		bcc 	_LIFindEnd
		;
		tya 								; that is step to the next
		clc 								; we don't bother bumping the 3rd byte
		adc 	zLTemp1 					; here. 
		sta 	zLTemp1
		bcc 	_LINoBump
		inc 	zLTemp1+1
_LINoBump: 									; done the lot ?
		dex 								; no go round again.
		bne 	_LITokenLoop
_LIFoundToken:
		ldy 	#0
_LIPrintToken:
		.if 	cpu="65816"					; get next token
		lda 	[zLTemp1],y
		.else
		lda 	(zLTemp1),y 		
		.endif
		cpy 	#0 							; see if needs prefix space
		bne 	_LINoPrefixSpace
		cmp 	#"A" 						; e.g. alphabetic token.
		bcc 	_LINoPrefixSpace
		cmp 	#"Z"+1
		bcs 	_LINoPrefixSpace
		ldx 	LastPrinted 				; if last was space not required
		cpx 	#" "
		beq 	_LINoPrefixSpace
		pha
		lda 	#" "
		jsr 	ListPrintLC
		pla
_LINoPrefixSpace:		
		iny
		pha 								; save it
		and 	#$7F
		jsr 	ListPrintLC
		pla 
		bpl 	_LIPrintToken 				; go back if not end 
		ply 								; restore Y
		and 	#$7F 						; if last char is a letter
		cmp 	#"A"
		bcc 	_LINotLetter2
		cmp 	#"Z"+1
		bcs 	_LINotLetter2
		lda 	#" " 						; add spacing
		jsr 	ListPrintLC
_LINotLetter2:		
		jmp 	_LIDecode

;
;		Print A in L/C ; note the interface makes it U/C again in the emulator ;-)
;
ListPrintLC:
		sta 	LastPrinted
		cmp 	#"A"
		bcc 	_LPLC0
		cmp 	#"Z"+1
		bcs 	_LPLC0
		adc 	#$20
_LPLC0:	jmp 	CharPrint				

; *******************************************************************************************
;
;							Get the range in Mantissa/Mantissa+6
;
; *******************************************************************************************

ListGetRange:	
		ldx 	#XS_Size*2-1 				; clear first 2 slots back to defaults.
_LGRClear:
		lda 	#0
		sta 	XS_Mantissa,x
		dex
		bpl 	_LGRClear 					
		#s_get 								; value present ?
		cmp 	#0 							; nothing
		beq 	_LGRBlank 					
		cmp 	#token_Colon 				; or colon
		beq 	_LGRBlank
		cmp 	#token_Comma 				; comma
		beq 	_LGREnd 					; then it's LIST ,x
		jsr 	EvaluateInteger 			; get the first number into bottom
		#s_get 								; if - follows that
		cmp 	#token_Comma
		beq 	_LGREnd 					; then it is LIST a,b
		;
		lda 	XS_Mantissa+0 				; copy first to second LIST n is n,n
		sta 	XS_Mantissa+XS_Size+0
		lda 	XS_Mantissa+1
		sta 	XS_Mantissa+XS_Size+1		
		;
_LGRBumpExit:
		inc 	XS_Mantissa+XS_Size 		; bump it so we can use cc.
		bne 	_LGRBump2
		inc 	XS_Mantissa+XS_Size+1
_LGRBump2:
		rts				

_LGREnd:
		#s_next 							; skip the minus.	
_LGRBlank:			
		lda 	#$FF 						; default to the end.
		sta 	XS_Mantissa+XS_Size
		sta 	XS_Mantissa+XS_Size+1
		#s_get 								; what's next ?
		cmp 	#0
		beq 	_LGRBump2
		asl 	a 							; if not a number, then exit (to end)
		bcs 	_LGRBump2
		ldx 	#XS_Size 					; get to range
		jsr 	EvaluateIntegerX
		bra 	_LGRBumpExit
		rts

; *******************************************************************************************
;
;				Return CC if list in range of mantissa,mantissa+size
;
; *******************************************************************************************

ListCheckRange:		
		#s_next 							; point to line number low
		ldx 	#0 							; test low
		jsr 	_LCRCompare
		bcc 	_LCRFail
		ldx 	#XS_Size 					; test high
		jsr 	_LCRCompare
		rts
_LCRFail:
		sec
		rts
_LCRCompare:								; compare line number vs mantissa,X
		#s_get
		sec 
		sbc	 	XS_Mantissa+0,x
		php
		#s_next
		#s_get
		plp
		sbc 	XS_Mantissa+1,x
		php
		#s_prev
		plp
		rts	