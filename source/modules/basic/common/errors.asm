; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		errors.asm
;		Purpose :	Basic Main Core
;		Date :		23rd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;								General Errors
;
; *******************************************************************************************

SyntaxError:
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
		#s_startLine 						; start (offset) of current line.
		#s_next 							; LSB line
		#s_get
		sta 	XS_Mantissa 
		#s_next 							; MSB line
		#s_get
		sta 	XS_Mantissa+1 
		plx 								; address in XY
		ply
		inx 								; bump, because of RTS/JSR address -1
		bne 	_EHNoSkip
		iny
_EHNoSkip:
		jsr 	PrintROMMessage 			; print message from ROM.
		lda 	XS_Mantissa					; line number = 0
		ora 	XS_Mantissa+1
		beq 	_EHNoLine
		ldx 	#_EHAt & $FF 				; print " at "
		ldy 	#(_EHAt >> 8) & $FF
		jsr 	PrintROMMessage
		ldx 	#0 							; Print line number
		jsr 	Print16BitInteger 
_EHNoLine:		
		.if 	exitOnEnd != 0
		bra 	_EHNoLine
		.endif
		jmp 	WarmStart

_EHAt:	.text 	" at ",0		


; *******************************************************************************************
;
;			Print message at XY in ROM. Seperate code because of 65816/K issue
;
; *******************************************************************************************

PrintROMMessage:
		stx 	zLTemp1 					; save addres
		sty 	zLTemp1+1
		.if 	cpu="65816"					; 65816, make it 24 bit address.
		phk
		pla
		sta 	ZLTemp1+2
		.endif
		ldy 	#0
_PRMLoop:
		.if 	cpu="65816" 				; get next.
		lda 	[zLTemp1],y
		.else
		lda 	(zLTemp1),y
		.endif
		beq		_PRMExit
		iny 
		jsr 	IFT_PrintCharacter
		bra 	_PRMLoop
_PRMExit:
		rts		

; *******************************************************************************************
;
;				Print value in mantissa,x as 16 bit integer unsigned
;
; *******************************************************************************************

Print16BitInteger:
		lda 	#0 							; make 32 bit
		sta 	XS_Mantissa+2
		sta 	XS_Mantissa+3
		sta 	NumBufX 					; reset the conversion pointer
		tax 								; convert bottom level.
		jsr 	INTToString 				; make string
		ldx 	#0 							; print buffer
_P1Loop:lda 	Num_Buffer,x
		beq 	_P1Exit
		jsr 	IFT_PrintCharacter
		inx
		bra 	_P1Loop
_P1Exit:rts
