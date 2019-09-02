; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		skip.asm
;		Purpose :	Structure Skipping Code
;		Date :		29th August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************
;
;	Note: Logically this should belong in structure ; however because of the two 
;		  format IF it will be built in whether you add the new structures or not.
;
; *******************************************************************************************
;
;		Scan forward for a structure-close looking for A or X/A, tracking open/close 
;		program structure forwards. On exit points to token.
;
; *******************************************************************************************

StructureSearchSingle:
		ldx 	#0 							; we always search for XA. This disables X.
		;
StructureSearchDouble:
		sta 	zTemp1 						; save the targets in zTemp1,zTemp1+1
		stx 	zTemp1+1
		lda 	#0 							; set the structure depth to zero (zTemp2)
		sta 	zTemp2
		bra 	_SSWLoop 					; jump in, start scanning from here.
		;
		;			Start a new line, check if end of program, error if so.
		;
_SSWNextLine:
		#s_nextLine 						; go to next line.
		#s_startLine 						; start of line.
		#s_get 								; get offset
		cmp 	#0					 		; if zero, fail.	
		beq 	_SSWFail 			
		#s_next 							; go to first character
		#s_next 							; (after all 3 s_next)
		;
		;			Go to next character, simple one.
		;
_SSWNextSimple:		
		#s_next
		;
_SSWLoop:
		#s_get 								; look at token.
		cmp 	#0 							; end of line ?
		beq 	_SSWNextLine 				; if so, then next line
		bpl 	_SSWNextSimple 				; needs to be a token, just skip char/number.
		;		
		;			Found a token.
		;
		ldx 	zTemp2 						; check structure count
		bne 	_SSWCheckUpDown 			; if it's non zero, then a match doesn't work.
		;
		cmp 	zTemp1 						; found the right keyword, either choice.
		beq 	_SSWFound 					; then exit.
		cmp 	zTemp1+1
		beq 	_SSWFound
		;
		;		For token in A, see if it adjusts the keyword level count.
		;
_SSWCheckUpDown:
		cmp 	#firstKeywordPlus 			; if < keyword +
		bcc 	_SSWNext
		cmp 	#firstKeywordMinus 			; if < keyword - then as keyword +
		bcc 	_SSWPlus
		cmp 	#firstUnaryFunction			; if < first unary down as keyword -
		bcs 	_SSWNext 
		dec 	zTemp2 						; reduce structure count.
		dec 	zTemp2 						
_SSWPlus:
		inc 	zTemp2		
		bmi 	_SSWUnder					; error if driven -ve
_SSWNext:
		;
		;		Skip over token, print or whatever, and go round again.
		;
		#s_skipelement 						; skip an element
		bra 	_SSWLoop 					
		;
_SSWFound:
		rts		

_SSWUnder:									; count has gone negative
		#Fatal	"Structure order"		
_SSWFail:									; couldn't find it and ran off the end.
		#Fatal	"Can't find structure"

; *******************************************************************************************
;
;						Advance pointer to end of command
;
; *******************************************************************************************

SkipEndOfCommand:
		#s_get 								; get next token
		cmp 	#0 							; if zero, end of line, so exit
		beq 	_SOCExit
		cmp 	#token_Colon 				; if colon, end of command
		beq 	_SOCExit
		#s_skipElement 						; go forward
		bra 	SkipEndOfCommand
_SOCExit:
		rts		

