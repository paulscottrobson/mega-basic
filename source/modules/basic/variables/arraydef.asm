; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		arraydef.asm
;		Purpose :	Array creation
;		Date :		26th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;							Reset the default sizes for arrays
;
; *******************************************************************************************

ArrayResetDefault:
		lda 	#11 						; 0..10 one array
		sta 	ArrayDef+0
		lda 	#0
		sta 	ArrayDef+1
		lda 	#$FF
		sta 	ArrayDef+2 					; $FFFF implies no second element.
		sta 	ArrayDef+3					; (test bit 7 of 2nd byte)

;		lda 	#3 							; Bodge default to be (3,4) elements not 11
;		sta 	ArrayDef+0
;		lda 	#4
;		sta 	ArrayDef+2
;		lda 	#0
;		sta 	ArrayDef+3
;		lda 	#$FF
;		sta 	ArrayDef+4
;		sta 	ArrayDef+5
		rts

; *******************************************************************************************
;
;			Create an array defined by offset X (either array of pointers or data)
;			return address in YA.
;
;			This is called recursively to create multiple levels. The maximum DIMs
;			is set to 3, but this is arbitrary and can be changed.
;
; *******************************************************************************************

ArrayCreate:
		;
		;		Firstly, calculate the size.
		;
		lda 	ArrayDef+0,x 				; put size x 2 in zTemp1 
		asl 	a
		sta 	zTemp1	
		lda 	ArrayDef+1,x
		rol 	a
		sta 	zTemp1+1
		;
		lda 	ArrayDef+3,x 				; if this is the last element it's array of ptrs.
		bpl 	_ACSized 					; if not multiply size x 2 (str) 4 (int) 5 (real)
		;
		lda 	Var_Type 					; check the type
		cmp 	#token_DollarLParen 		; also if it is an array of strings $(
		beq 	_ACSized
		;
		asl 	zTemp1 						; double again
		rol 	zTemp1+1
		bcs 	ArrayIndexError 			; too large.
		;
		cmp 	#token_PercentLParen 		; if %( four bytes/entry is enough.
		beq 	_ACSized
		;
		clc 								; add original value x 5 for reals.
		lda 	zTemp1
		adc 	ArrayDef+0,x
		sta 	zTemp1
		lda 	zTemp1+1
		adc 	ArrayDef+1,x
		sta 	zTemp1+1
		bcs 	ArrayIndexError
_ACSized:				
		;
		;		Add 2 for the array information header
		;
		clc
		lda 	zTemp1					
		adc 	#2
		sta 	zTemp1
		bcc 	_ACNoBump
		inc 	zTemp1
		beq 	ArrayIndexError
		;
		;		Allocate memory for it.
		;
_ACNoBump:		
		clc
		lda 	VarMemPtr 					; add this allocated count to VarMemPtr
		sta 	zTemp2						; save start in zTemp2/zTemp3
		sta 	zTemp3
		adc 	zTemp1
		sta 	VarMemPtr
		lda 	VarMemPtr+1
		sta 	zTemp2+1
		sta 	zTemp3+1
		adc 	zTemp1+1
		sta 	VarMemPtr+1
		sta 	zTemp1+1
		bcs 	ArrayIndexError
		;
		;		Clear the whole memory space.
		;
		ldy 	#0							; write $00 out.		
_ACClear:
		tya
		sta 	(zTemp2),y
		inc 	zTemp2
		bne 	_ACCBump
		inc 	zTemp2+1
_ACCBump:		
		lda 	zTemp2
		cmp 	VarMemPtr
		bne 	_ACClear
		lda 	zTemp2+1
		cmp 	VarMemPtr+1
		bne 	_ACClear		
		;
		ldy 	#0
		lda 	ArrayDef+0,x 				; copy the size into the start
		sta 	(zTemp3),y
		iny
		lda 	ArrayDef+1,x
		sta 	(zTemp3),y
		;
		lda 	ArrayDef+3,x 				; have we reached the end
		bpl 	ACCFillRecursive

		ldy 	zTemp3+1 					; return address
		lda 	zTemp3
		rts

ArrayIndexError:		
		#Fatal	"Bad array index"

ACCFillRecursive:
		lda 	#$FF 						; we mark the end, this is free space.
		ldy 	#0 							; this is overwritten by size of next allocated
		sta 	(zTemp2),y 					; array, but we might change that.
		iny
		lda 	(zTemp3),y 					; set bit 15 of the max index indicating
		ora 	#$80 						; an array of pointers
		sta 	(zTemp3),y
		;
		lda 	zTemp3 						; push the start on the stack
		pha
		lda 	zTemp3+1
		pha
		;
_ACCFillLoop:
		clc		
		lda 	zTemp3 						; and work forwards.
		adc 	#2
		sta 	zTemp3
		bcc 	_ACCSkip2
		inc 	zTemp3+1
_ACCSkip2:
		ldy 	#0 							; reached the end ?			
		lda 	(zTemp3),y					; (looking for FF marker, everything else 00)
		iny
		ora 	(zTemp3),y
		bne 	_ACCExit
		;
		lda 	zTemp3 						; push zTemp3
		pha
		lda 	zTemp3+1
		pha
		;
		inx
		inx
		jsr 	ArrayCreate 				; create array recursively.
		dex
		dex
		sta 	zTemp2 						; save A
		pla
		sta 	zTemp3+1 					; restore zTemp3
		pla
		sta 	zTemp3
		tya 								; write high bye from Y
		ldy 	#1 	
		sta 	(zTemp3),y
		dey 								; write low byte out.
		lda 	zTemp2
		sta 	(zTemp3),y
		bra 	_ACCFillLoop 				; and try again.
		;
_ACCExit:
		ply 								; restore the original address
		pla
		rts		
