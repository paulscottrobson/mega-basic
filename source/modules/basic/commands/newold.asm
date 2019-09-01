; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		newold.asm
;		Purpose :	New/Old Command
;		Date :		23rd August 2019
;		Review : 	1st September 2019
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
		lda 	#0 							; write a 0 there, null first offset
		#s_put		
		jsr 	UpdateProgramEnd 			; update program end.
		jmp 	WarmStart 					; and always warmstart, can't be running program.

; *******************************************************************************************
;
;									Undoes Command_NEW
;
; *******************************************************************************************
		
Command_OLD: ;; old
		#s_toStart 							; first token of the program.
_COL_Find:
		#s_get 								; get next and advance
		#s_next
		cmp 	#0 							; if zero, then the position Y/Z is new offset
		beq 	_COL_Found
		#s_OffsetToA 						; has the offset looped round to 0
		cmp 	#0 							; e.g. there is no program line end.
		bne 	_COL_Find 					; can't find old EOL, give up.
		#Fatal 	"Program Corrupt"
		;
_COL_Found:
		#s_offsetToA 						; get offset of the first $00
		pha
		#s_startLine 						; right to the start, e.g. position first offset
		pla
		#s_put 								; overwrite offset
		jsr 	UpdateProgramEnd 			; reset variable pointer
		rts
