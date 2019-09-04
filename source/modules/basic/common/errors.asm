; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		errors.asm
;		Purpose :	Basic Main Core
;		Date :		23rd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;								General Errors
;
; *******************************************************************************************

SyntaxError: 								; Some standard error types
		jsr 	ERR_Handler
		.text 	"Syntax Error",0
TypeError:
		jsr 	ERR_Handler
		.text 	"Wrong type",0
BadParamError:
		jsr 	ERR_Handler
		.text 	"Bad Parameter",0

; *******************************************************************************************
;
;									Report any error
;
; *******************************************************************************************

ERR_Handler:
		;
		;		Copy the line number into the Mantissa.
		;
		#s_startLine 						; start (offset) of current line.
		#s_next 							; LSB line
		#s_get
		sta 	XS_Mantissa 
		#s_next 							; MSB line
		#s_get
		sta 	XS_Mantissa+1 
		;
		;		Get the message address, which follows the JSR ERR_Handler call
		;
		plx 								; address in XY
		ply
		inx 								; bump, because of RTS/JSR address -1
		bne 	_EHNoSkip
		iny
		;
		;		Print message, and optionally " AT <line number>"
		;
_EHNoSkip:
		jsr 	PrintROMMessage 			; print message from ROM.
		lda 	XS_Mantissa					; line number = 0
		ora 	XS_Mantissa+1
		beq 	_EHNoLine
		;
		ldx 	#_EHAt & $FF 				; print " at "
		ldy 	#(_EHAt >> 8) & $FF
		jsr 	PrintROMMessage
		;
		ldx 	#0 							; Print line number
		jsr 	Print16BitInteger 
_EHNoLine:									; if running in automatic mode, we 
		.if 	exitOnEnd != 0 				; stop dead on an error.
		bra 	_EHNoLine
		.endif
		lda 	#13
		jsr 	VIOCharPrint
		jmp 	ErrorStart 					; normally warm start, no message.

_EHAt:	.text 	" at ",0		


; *******************************************************************************************
;
;			Print message at XY in ROM. Seperate code because of 65816/K issue
;
; *******************************************************************************************

PrintROMMessage:
		stx 	zLTemp1 					; save addres
		sty 	zLTemp1+1
		.if 	cpu=="65816"				; 65816, make it 24 bit address.
		phk 								; get current code page
		pla
		sta 	ZLTemp1+2 					; put into the 3rd byte so we can use
		.endif 								; ld [xxx],y
		ldy 	#0
_PRMLoop:
		.if 	cpu=="65816" 				; get next character
		lda 	[zLTemp1],y 				; 65816
		.else
		lda 	(zLTemp1),y 				; 6502/4510
		.endif
		beq		_PRMExit 					; character $00 => exit
		iny  								; bump Y and print it.
		jsr 	VIOCharPrint
		bra 	_PRMLoop
_PRMExit:
		rts		

; *******************************************************************************************
;
;				Print value in mantissa,x as 16 bit integer unsigned.
; 				Returns characters printed in the process in A 
;				(used by LIST to align)
;
; *******************************************************************************************

Print16BitInteger:
		lda 	#0 							; make 32 bit
		sta 	XS_Mantissa+2
		sta 	XS_Mantissa+3
;
;		Can jump in here to print a 32 bit unsigned integer.
;
Print32BitInteger:
		lda 	#0		
		sta 	NumBufX 					; reset the conversion pointer
		tax 								; convert bottom level.
		jsr 	INTToString 				; make string from integer in Num_Buffer
		ldx 	#0 							; print buffer contents
_P1Loop:lda 	Num_Buffer,x
		beq 	_P1Exit
		jsr 	VIOCharPrint
		inx
		bra 	_P1Loop
_P1Exit:txa 								; return chars printed.
		rts

