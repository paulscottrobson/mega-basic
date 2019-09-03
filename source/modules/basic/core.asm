; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		core.asm
;		Purpose :	Basic Main Core
;		Date :		19th August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

		.include "../basic/header/header.src"

BASIC_Start:
		jsr 	IF_Reset 					; set up and clear screen.
		jsr 	IFT_ClearScreen
		;
		.if 	cpu=="65816"
		lda 	#$5C 						; JMP Long opcode
		.else
		lda 	#$4C 						; JMP opcode
		.endif
		sta 	LocalVector
		sta 	UserVector
		lda 	#USRDefault & $FF 			; reset USR vector to a default
		sta 	UserVector+1 				; 24 / 16 bit address
		lda 	#(USRDefault >> 8) & $FF 	; e.g. it becomes JMP USRDefault
		sta 	UserVector+2		
		lda 	#(USRDefault >> 16) & $FF
		sta 	UserVector+3
		;
		jsr 	UpdateProgramEnd 			; update the program end.
		;
		jsr 	ResetRunStatus 				; clear everything (CLR command)
		;
		#ResetStack
		.if 		loadTest!=0
		jmp 	COMMAND_Run
		.endif
		;
;		jsr 	Command_NEW 				; new command, will not return.
WarmStart:
		#ResetStack
		;
		; 	TODO: Input and execute command. Not this way (!)
		;		
		bra 	WarmStart
		