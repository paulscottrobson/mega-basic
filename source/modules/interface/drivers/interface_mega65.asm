; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		interface_mega65.asm
;		Purpose :	Assembler Interface (Mega65 Hardware)
;		Date :		18th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

IF_Width 	= 80 							; characters across
IF_Height 	= 25 							; characters down.

IF_Pos 		= 4 							; current position, start of line
IF_XPos 	= 6 							; current position, horizontal.
IF_FarPtr 	= 8 							; far pointer (4 bytes)

IF_Screen = $1000							; 2k screen RAM here
IF_CharSet = $800							; 2k character set (0-7F) here

; *******************************************************************************************
;
;										  Home cursor
;
; *******************************************************************************************

IF_Home:
		pha 								; reset cursor position
		lda 	#IF_Screen & $FF
		sta 	IF_Pos
		lda 	#IF_Screen >> 8
		sta 	IF_Pos+1
		lda 	#0
		sta 	IF_XPos
		pla
		rts

; *******************************************************************************************
;
;									 Start of next line
;
; *******************************************************************************************

IF_NewLine:
		pha
		lda 	#0 							; back to start of line
		sta 	IF_XPos
		clc 								; down one line
		lda 	IF_Pos
		adc 	#80
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
		lda 	(IF_Pos),y
		eor 	#$20
		clc
		adc 	#$20
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
		and 	#63+128 					; PETSCII
		sta 	(IF_Pos),y
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
		phz
		jsr 	IF_SetupKeyAddress 			; point to keyboard
		inc 	IF_FarPtr 					; point to modifiers.
		nop 								; read modifiers.
		lda 	(IF_FarPtr),z
		plz 								; restore Z
		and 	#5							; break is LeftShift+Ctrl
		cmp 	#5 		
		beq 	_IF_CBExit
		lda 	#0
_IF_CBExit:									; returns A=5/0 Z flag
		cmp 	#0
		rts

; *******************************************************************************************
;
;									Get one key press in A, Z set
;
; *******************************************************************************************

KeyMap:	.macro 								; keyboard mapping macro.
		cmp 	#\1
		bne 	_KMNo
		lda 	#\2
_KMNo:
		.endm

IF_GetKey:
		phz
		jsr 	IF_SetupKeyAddress
		nop 								; read keyboard
		lda 	(IF_FarPtr),z 
		keymap 	20,"H"-64
		keymap 	145,"W"-64
		keymap 	17,"S"-64
		keymap	157,"A"-64
		keymap	29,"D"-64
		cmp 	#0
		beq 	_IFGKEmpty
		pha
		lda 	#0
		nop
		sta 	(IF_FarPtr),z
		pla
_IFGKEmpty:		
		plz		
		cmp 	#0 							; set Z
		rts

IF_SetupKeyAddress:
		lda 	#$0F 						; set up to write to read keyboard.
		sta 	IF_FarPtr+3
		lda 	#$FD
		sta 	IF_FarPtr+2
		lda 	#$36
		sta 	IF_FarPtr+1
		lda 	#$10
		sta 	IF_FarPtr+0	
		ldz 	#0 			
		rts

; *******************************************************************************************
;
;									  Reset the interface
;
; *******************************************************************************************

IFWriteHW 	.macro 							; write to register using
		ldz 	#\1 						; address already set up
		lda 	#\2
		nop
		sta 	(IF_FarPtr),z
.endm

IF_Reset:
		pha 								; save registers
		phx
		phy
		lda 	#$0F 						; set up to write to video system.
		sta 	IF_FarPtr+3
		lda 	#$FD
		sta 	IF_FarPtr+2
		lda 	#$30
		sta 	IF_FarPtr+1
		lda 	#$00
		sta 	IF_FarPtr+0

		#IFWriteHW 	$2F,$47 				; switch to VIC-IV mode ($A5/$96 VIC III)
		#IFWriteHW 	$2F,$53	

		#IFWriteHW 	$30,$40					; C65 Charset 					
		#IFWriteHW 	$31,$80+$40 			; 80 column mode, 40Mhz won't work without 3.5Mhz on.

		#IFWriteHW $20,0 					; black border
		#IFWriteHW $21,0 					; black background

		#IFWriteHW $54,$40 					; Highspeed on.

		#IFWriteHW $01,$FF
		#IFWriteHW $00,$FF

		#IFWriteHW $16,$CC 					; 40 column mode

		#IFWriteHW $18,$42	 				; screen address $0800 video address $1000
		#IFWriteHW $11,$1B 					; check up what this means

		lda 	#$00						; colour RAM at $1F800-1FFFF (2kb)
		sta 	IF_FarPtr+3 
		lda 	#$01
		sta 	IF_FarPtr+2
		lda 	#$F8
		sta 	IF_FarPtr+1
		lda 	#$00
		sta 	IF_FarPtr+0
		ldz 	#0 
_EXTClearColorRam:	
		lda 	#5							; fill that with this colour.
		nop
		sta 	(IF_FarPtr),z
		dez
		bne 	_EXTClearColorRam
		inc 	IF_FarPtr+1
		bne 	_EXTClearColorRam

		ldx 	#0 							; copy PET Font into memory.
_EXTCopyCBMFont:
		lda 	IF_CBMFont,x 				; +$800 uses the lower case c/set
		sta 	IF_CharSet,x
		eor 	#$FF
		sta 	IF_CharSet+$400,x
		lda 	IF_CBMFont+$100,x
		sta 	IF_CharSet+$100,x
		eor 	#$FF
		sta 	IF_CharSet+$500,x
		lda 	IF_CBMFont+$200,x
		sta 	IF_CharSet+$200,x
		eor 	#$FF
		sta 	IF_CharSet+$600,x
		lda 	IF_CBMFont+$300,x
		sta 	IF_CharSet+$300,x
		eor 	#$FF
		sta 	IF_CharSet+$700,x
		dex
		bne 	_EXTCopyCBMFont

		lda 	#$3F-4  					; puts ROM back in the map (the -4)
		sta 	$01

		lda 	#$00						; do not map bytes 0000-7FFF
		ldx 	#$00						; (so we use the RAM physically at $0000-$7FFF)

		ldy 	#$00 						; 8000-FFFF offset by $200. The lower 8 bits are $00
		ldz 	#$F2 						; so this is an actual offset of $20000. So the space at
											; 8000-FFFF is mapped to 28000-2FFFF.
		map
		eom

		ply 								; restore and exit.
		plx
		pla

		rts

IF_CBMFont:
		.binary "pet-font.bin"
