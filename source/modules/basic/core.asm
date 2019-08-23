; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		core.asm
;		Purpose :	Basic Main Core
;		Date :		19th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

		.include "../basic/header/header.src"

BASIC_Start:
		jsr 	IF_Reset 					; set up and clear screen.
		jsr 	IFT_ClearScreen
		;
		.if 	cpu="65816"
		lda 	#$5C 						; JMP Long opcode
		.else
		lda 	#$4C 						; JMP opcode
		.endif
		sta 	LocalVector
		sta 	UserVector
		lda 	#USRDefault & $FF 			; reset USR vector
		sta 	UserVector+1
		lda 	#(USRDefault >> 8) & $FF
		sta 	UserVector+2		
		lda 	#(USRDefault >> 16) & $FF
		sta 	UserVector+3
		;
		jsr 	ResetRunStatus 				; clear everything (CLR command)
		;
		; 	TODO: NEW, maybe.
		;
WarmStart:
		#ResetStack
		;
		;	TODO: Reset BASIC stack
		; 	TODO: Input and execute command.
		;		
		jmp 	COMMAND_Run

