; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		clr.asm
;		Purpose :	CLR Command
;		Date :		22nd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									CLR Command
;
; *******************************************************************************************

Command_CLR: 	;; clr

; *******************************************************************************************
;	
;								  Clear Runtime 
;
; *******************************************************************************************

ResetRunStatus:
		;
		;		Clear Variables
		;
		jsr 	VariableClear
		;
		;		TODO:Reset Basic Stack.
		;

		;
		;		Reset the string pointer space which is allocated downwards
		;
		lda 	#HighMemory & $FF
		sta 	StringPtr
		lda 	#HighMemory >> 8
		sta 	StringPtr+1
		jsr 	ArrayResetDefault
		rts
		