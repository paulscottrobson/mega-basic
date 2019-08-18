; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		interface_em65816.asm
;		Purpose :	Assembler Interface (65816 Emulator version)
;		Date :		18th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

IF_Width 	= 64 							; characters across
IF_Height 	= 32 							; characters down.

IF_Pos 		= 4 							; current position, start of line.
IF_XPos 	= 8 							; current position, horizontal.

IF_Screen = $F0000							; 2k screen RAM here
IF_PKeyboard = $F8010						; Keyboard port.
IF_PBreak = $F8000 							; Break key.

; *******************************************************************************************
;
;									  Reset the interface
;
; *******************************************************************************************

IF_Reset:
		rts

; *******************************************************************************************
;
;										  Home cursor
;
; *******************************************************************************************

IF_Home:
		pha
		stz 	IF_XPos 					; zero X position	
		lda 	#IF_Screen & $FF 			; set r/w pos.
		sta 	IF_Pos
		lda 	#(IF_Screen >> 8) & $FF
		sta 	IF_Pos+1
		lda 	#IF_Screen >> 16  		
		sta 	IF_Pos+2
		stz 	IF_Pos+3
		pla
		rts

; *******************************************************************************************
;
;									 Start of next line
;
; *******************************************************************************************

IF_NewLine:
		pha
		stz 	IF_XPos						; back to start of line
		clc 								; down one line
		lda 	IF_Pos
		adc 	#64
		sta 	IF_Pos
		bcc 	_IF_NoCarry 				; carry through.
		inc 	IF_Pos+1
_IF_NoCarry:
		pla
		rts

; *******************************************************************************************
;
;									  Read a character.
;
; *******************************************************************************************

IF_Read:
		phy 								; save current Y
		ldy 	IF_XPos 					; read character at current position
		lda 	[IF_Pos],y
		inc 	IF_XPos 					; step right.
		ply									; restore Y
		rts

; *******************************************************************************************
;
;									  Write a character.
;
; *******************************************************************************************

IF_Write:
		phy 								; save current Y
		ldy 	IF_XPos 					; write character at current position
		sta 	[IF_Pos],y
		inc 	IF_XPos 					; step right.
		ply									; restore Y
		rts

; *******************************************************************************************
;
;										Undo right-move
;
; *******************************************************************************************

IF_LeftOne:
		dec 	IF_XPos
		rts
		
; *******************************************************************************************
;
;						Check if break pressed, return A != 0 if so, Z set.
;
; *******************************************************************************************

IF_CheckBreak:
		lda 	IF_PBreak					; non-zero if Ctrl+C pressed.
		rts

; *******************************************************************************************
;
;									Get one key press in A, Z set
;
; *******************************************************************************************

IF_GetKey:
		lda 	IF_PKeyboard				; read keyboard
		beq		_IFGK_NoKey 				; skip if zero,no key pressed
		pha 								; key pressed, clear queue.
		lda 	#0							
		sta 	IF_PKeyboard
		pla
_IFGK_NoKey:
		ora 	#0							; set Z flag appropriately.
		rts

