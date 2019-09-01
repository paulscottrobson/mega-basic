; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		interface_tools.asm
;		Purpose :	Interface routines
;		Date :		18th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;										Clear Screen
;
; *******************************************************************************************

IFT_ClearScreen:
		pha
		phx
		phy
		jsr 	IF_Home 					; home cursor
		ldx 	#IF_Height 					; this many lines.
_IFT_CS0:
		ldy 	#IF_Width 					; this many chars/line
_IFT_CS1:
		lda 	#' '						; clear line.
		jsr 	IF_Write
		dey
		bne 	_IFT_CS1
		jsr 	IF_NewLine 					; next line down
		dex
		bne 	_IFT_CS0
		ply
		plx
		pla

; *******************************************************************************************
;
;										Home Cursor
;
; *******************************************************************************************

IFT_HomeCursor:
		pha
		jsr 	IF_Home
		lda 	#0
		sta 	IFT_XCursor
		sta 	IFT_YCursor
		pla
		rts

; *******************************************************************************************
;
;										Up one line
;
; *******************************************************************************************

IFT_UpLine:	
		pha
		lda  	IFT_YCursor 				; get Y
		dec 	a 							; line above
		bmi 	_IFTULExit 					; too far, abort
		jsr 	IFT_SetYPos					; set to that line.
_IFTULExit:
		pla
		rts

; *******************************************************************************************
;
;							Print Character on screen (ASCII in A)
;
; *******************************************************************************************

IFT_PrintCharacter:
		cmp 	#13 						; handle newline.
		beq 	IFT_NewLine
		cmp 	#8
		beq 	_IFT_Left
		pha
		jsr 	IFT_UpperCase 				; make upper case
		jsr 	IF_Write 					; write out.
		inc 	IFT_XCursor 				; bump x cursor
		lda 	IFT_XCursor 				; reached RHS ?
		cmp 	#IF_Width
		bne 	_IFT_PCNotEOL
		jsr 	IFT_NewLine 				; if so do new line.
_IFT_PCNotEOL:		
		pla
		rts
_IFT_Left:
		pha
		jsr 	IF_LeftOne
		pla
		rts


; *******************************************************************************************
;
;									 	Go to next line
;
; *******************************************************************************************

IFT_NewLine:
		pha
		jsr 	IF_NewLine 					; new line on actual screen.
		lda 	#0 							; reset x position
		sta 	IFT_XCursor
		inc 	IFT_YCursor 				; move down.
		lda 	IFT_YCursor
		cmp 	#IF_Height 					; reached bottom.
		bne 	_IFT_NL_NotEOS
		jsr 	IFT_Scroll 					; scroll screen up.
_IFT_NL_NotEOS:		
		pla
		rts

; *******************************************************************************************
;
;								Capitalise ASCII character
;
; *******************************************************************************************

IFT_UpperCase:
		cmp 	#"a"
		bcc 	_IFT_UCExit
		cmp 	#"z"+1
		bcs 	_IFT_UCExit
		eor 	#$20
_IFT_UCExit:
		rts

IFT_Scroll:
		pha 								; save AXY
		phx
		phy
		ldx 	#0 							; start scrolling.
_IFT_SLoop:
		jsr 	_IFT_ScrollLine 			; scroll line X+1 => X
		inx
		cpx 	#IF_Height-1				; do whole screen
		bne 	_IFT_SLoop
		lda 	#IF_Height-1 				; move to X = 0,Y = A
		jsr 	IFT_SetYPos
		ldx 	#IF_Width 					; blank line
_IFT_SBlank:
		lda 	#32
		jsr 	IF_Write
		dex
		bne 	_IFT_SBlank
		;
		lda 	#IF_Height-1 				; move to X = 0,Y = A
		jsr 	IFT_SetYPos
		ply
		plx
		pla
		rts

_IFT_ScrollLine:
		phx
		phx
		txa 								; copy line into buffer.
		inc 	a 							; next line down.
		jsr 	IFT_SetYPos
		ldx 	#0
_IFTScrollCopy1:
		jsr 	IF_Read
		sta 	IFT_Buffer,x
		inx
		cpx 	#IF_Width
		bne 	_IFTScrollCopy1
		pla
		jsr 	IFT_SetYPos
		ldx 	#0
_IFTScrollCopy2:
		lda 	IFT_Buffer,x
		jsr 	IF_Write
		inx
		cpx 	#IF_Width
		bne 	_IFTScrollCopy2
		plx
		rts		

; *******************************************************************************************
;
;										Move to (0,A)
;
; *******************************************************************************************

IFT_SetYPos:
		pha
		phx
		tax
		jsr 	IFT_HomeCursor
		cpx 	#0
		beq 	_IFT_MOAExit
_IFT_MOALoop:
		jsr 	IF_NewLine
		inc 	IFT_YCursor
		dex 	
		bne		_IFT_MOALoop
_IFT_MOAExit:	
		plx
		pla
		rts

; *******************************************************************************************
;
;							Get key, showing cursor highlight
;
; *******************************************************************************************

IFT_GetKeyCursor:
		jsr 	_IFT_FlipCursor 			; reverse current
_IFT_GKCWait:
		jsr 	IF_GetKey 					; get key
		beq 	_IFT_GKCWait
_IFT_FlipCursor:
		pha 								; save
		jsr 	IF_Read 					; read
		jsr 	IF_LeftOne
		eor 	#$80 						; reverse
		jsr 	IF_Write 					; write
		jsr 	IF_LeftOne
		pla
		rts

; *******************************************************************************************
;
;									Read line into buffer
;
; *******************************************************************************************

IFT_ReadLine:
		pha
_IFT_RLLoop:
		jsr 	IFT_GetKeyCursor 			; get keystroke
		cmp 	#13							; return
		beq 	_IFT_RLExit 
		cmp 	#32 						; control character
		bcc 	_IFT_Control 
		jsr 	IFT_PrintCharacter
		bra 	_IFT_RLLoop
		;
_IFT_Control:	
		cmp 	#"A"-64
		beq 	_IFT_Left
		cmp 	#"D"-64
		beq 	_IFT_Right
		cmp 	#"W"-64
		beq 	_IFT_Up
		cmp 	#"S"-64
		beq 	_IFT_Down
		cmp 	#"H"-64
		beq 	_IFT_Backspace
		cmp 	#"Z"-64
		bne 	_IFT_RLLoop		
		jsr 	IFT_ClearScreen				; clear CTL-Z
		bra 	_IFT_RLLoop
		;
_IFT_Backspace:		
		lda 	IFT_XCursor 				; check not start of line.
		beq 	_IFT_RLLoop
		jsr 	IF_LeftOne
		lda 	#" "						; overwrite with space, drop through to left
		jsr 	IF_Write
		;
_IFT_Left:
		dec 	IFT_XCursor 				; left CTL-W
		bpl 	_IFT_Reposition
		lda 	#IF_Width-1
_IFT_SetX:		
		sta 	IFT_XCursor
		bra 	_IFT_Reposition
_IFT_Right:									; right CTL-D
		inc 	IFT_XCursor
		lda 	IFT_XCursor
		eor 	#IF_Width		
		beq 	_IFT_SetX
		bra 	_IFT_Reposition
		;
_IFT_Up:									; up CTL-A
		dec 	IFT_YCursor
		bpl 	_IFT_Reposition
		lda 	#IF_Height-1
_IFT_SetY:			
		sta 	IFT_YCursor
		bra 	_IFT_Reposition
_IFT_Down:									; down CTL-S
		inc 	IFT_YCursor
		lda 	IFT_YCursor
		eor 	#IF_Height
		beq 	_IFT_SetY
		;
_IFT_Reposition:
		lda 	IFT_XCursor 				; put cursor at xCursor,yCursor
		pha
		lda 	IFT_YCursor
		jsr 	IFT_SetYPos
		pla
		tax
		cpx 	#0
		beq 	_IFT_RLLoop
_IFT_MoveRight:
		jsr 	IF_Read
		inc 	IFT_XCursor
		dex
		bne 	_IFT_MoveRight
		jmp 	_IFT_RLLoop
		;		
_IFT_RLExit:								; CR-Exit.
		lda 	IFT_YCursor 				; go to start of line.
		jsr 	IFT_SetYPos
		ldx 	#0 							; read text into line.
_IFT_RLRead:
		jsr 	IF_Read
		sta 	IFT_LineBuffer,x
		inx
		cpx 	#IF_Width
		bne 	_IFT_RLRead
		;
_IFT_RL_Trim:								; trim RH spaces
		dex 	 							; previous char
		bmi 	_IFT_Found 					; gone too far
		lda 	IFT_LineBuffer,x			; go back if space
		cmp 	#" "
		beq 	_IFT_RL_Trim
_IFT_Found:		
		inx 								; forward to non-space
		lda 	#0							; make it ASCIIZ
		sta 	IFT_LineBuffer,x
		pla
		ldx 	#IFT_LineBuffer & $FF 		; put address in YX
		ldy 	#IFT_LineBuffer >> 8
		rts
