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
		.if 	loadTest!=0
		jmp 	COMMAND_Run
		.endif
		;
		jsr 	Command_NEW 				; new command, will not return.
WarmStart:
		ldx 	#ReadyMsg & $FF 			; Print READY.
		ldy 	#(ReadyMsg >> 8) & $FF
		jsr 	PrintROMMessage
ErrorStart:		
		#ResetStack
		jsr 	IFT_ReadLine 				; read line in.
		;
		lda 	#IFT_LineBuffer & $FF 		; tokenise it.
		ldx 	#IFT_LineBuffer >> 8
		jsr 	TokeniseString
		;
		lda 	TokeniseBuffer+3 			; what is first.
		and 	#$C0 						; is it a number 4000-7FFF
		cmp 	#$40
		beq 	EditLine 					; if true, go to edit line.
		#s_toStart TokeniseBuffer 			; reset pointer to token buffer.
		jmp 	RUN_NextCommand

ReadyMsg:
		.text 	"Ready.",13,0

EditLine:
		bra 	EditLine