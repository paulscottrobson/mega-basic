; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		run.asm
;		Purpose :	RUN Command
;		Date :		23rd August 2019
;		Review : 	5th September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Command_RUN: 	;; run
		jsr 	ResetRunStatus 				; clear, reset stacks etc.
		#s_toStart BasicProgram 			; start of program.
		;
		;		New line. Check offset is non-zero, if so END.
		;	
RUN_NewLine:				
		#s_startLine 						; go to start of instruction
		#s_get 								; get the offset
		#s_next 							; advance to first token
		#s_next
		#s_next 
		cmp 	#0 							; if the offset is zero then END.
		bne 	RUN_NextCommand
		jmp 	Command_END 				; go do the command code.
		;
		;		Skip one token.
		;		
RUN_Skip:
		#s_skipElement 						; skip over it.		
		;
		;		Execute the Next command
		;
RUN_NextCommand:
		;
		lda 	BreakCount 					; check the break counter
		adc 	#16 						; one time in 16
		sta 	BreakCount
		bcc 	RUN_NoCheckBreak
		jsr 	VIOCheckBreak 				; check for break
		cmp 	#0
		beq 	RUN_NoCheckBreak
		jmp 	Command_STOP 				; stop on BREAK.
RUN_NoCheckBreak:		
		;
		lda 	#0 							; this resets temporary string allocation.
		sta 	zTempStr+1 					; (initialised when first called)
		;
		#s_get 								; get the token or first character.
		cmp 	#token_Colon 				; skip over colons
		beq 	RUN_Skip
		cmp 	#0 							; if non-zero execute whatever
		bne 	RUN_Execute		 			; zero => end of the current line.
		;
		;		Advance to next line. If the line offset is $00 which it is in 
		;		direct mode, this will try to redo the current line. However, it
		;		checks for offset zero and exits if it is.
		;
RUN_NextLine:
		#s_nextline 						; go to the next line
		bra 	RUN_NewLine 				; go do the new line code
		;
		;		Execute command, token in A.
		;
RUN_Execute:
		cmp 	#$F8 						; handle shifts, REM etc.
		bcs 	RUN_Extension
		#s_next 							; skip over token.
		;
		asl 	a 							; double the character read.
		bcc 	RUN_Default 				; if carry clear was $00-$7F, so try LET.
		;
		tax 								; ready to look up.
		lda 	VectorTable,x 				; copy address into LocalVector
		sta 	LocalVector+1
		lda 	VectorTable+1,x
		sta 	LocalVector+2
		jsr 	EVCallLocalVector 			; execute the appropriate code.
		bra 	RUN_NextCommand 			; do the next command.
		;
		;		Not a token, so try LET instead
		;
RUN_Default:
		#s_prev 							; back one as no token
		jsr 	Command_LET 				; and try LET.
		bra 	RUN_NextCommand
		;
		;		Handle $F8-$FB (token shifts) $FF (Rem)
		;
RUN_Extension:
		cmp 	#$FF 						; if $FF (REM)
		beq 	RUN_Skip 					; skip over it
		;
		;		This is handling $F8-$FE. $FD, $FE are errors automatically.
		;		$F8-$FB are token shifts.
		;
		jmp 	SyntaxError

;
;		If you put :::::: in a program this just effectively NOPs it.
;
Command_COLON: 	;; : 				
		rts

