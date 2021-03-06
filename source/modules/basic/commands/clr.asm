; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		clr.asm
;		Purpose :	CLR Command
;		Date :		22nd August 2019
;		Review : 	1st September 2019
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
;
;		Fall through to ....
;

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
		;		Reset BASIC stack
		;
		jsr 	StackReset
		;
		;		Reset the string pointer space which is allocated downwards
		;
		lda 	#HighMemory & $FF
		sta 	StringPtr
		lda 	#HighMemory >> 8
		sta 	StringPtr+1
		;
		;		Reset the 'Array Default' - the structure created when an 
		;		array is auto-instantiated.
		;
		jsr 	ArrayResetDefault
		;
		;		Reset the READ/DATA pointer
		;
		jsr 	Command_RESTORE
		rts
		