; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		newold.asm
;		Purpose :	New/Old Command
;		Date :		23rd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;								Erase - simply the old program. 
;
; *******************************************************************************************

Command_NEW: 	;; new
		#s_toStart							; start of program memory
		#s_startLine 						; to start of line
		lda 	#0 							; write a 0 there.
		#s_put		
		jsr 	UpdateProgramEnd 			; update program end.
		jmp 	WarmStart

; *******************************************************************************************
;
;									Undoes Command_NEW
;
; *******************************************************************************************
		
Command_OLD: ;; old
		nop
		#s_toStart 							; first token
_COL_Find:
		#s_get 								; get next and advance
		#s_next
		cmp 	#0 							; if zero, then the position Y/Z is new offset
		beq 	_COL_Found
		#s_OffsetToA 						; so check that
		cmp 	#0
		bne 	_COL_Find 					; can't find old EOL, give up.
		#Fatal 	"Program Corrupt"
		;
_COL_Found:
		#s_offsetToA 						; get offset
		pha
		#s_startLine 						; right to the start
		pla
		#s_put 								; overwrite offset
		jsr 	UpdateProgramEnd 			; reset variable pointer
		rts
