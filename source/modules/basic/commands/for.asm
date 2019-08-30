; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		for.asm
;		Purpose :	FOR/NEXT Command
;		Date :		30th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Command_FOR: 	;; for
		;
		;		Start of with a Let FOR [I = xxxx] which leaves the pointer set up.
		;
		jsr 	Command_LET 				; do the A = 99 bit
		lda 	zVarType 					; obviously has to be integer/real.
		cmp 	#token_Dollar
		beq 	_CFOError

		pha 								; save the variable type.

		phy 								; save type/variable address.
		ldy 	#1							; type at + 1
		sta 	(zBasicSP),y 	
		iny
		lda 	zVarDataPtr 				; data low at +2
		sta 	(zBasicSP),y 	
		iny
		lda 	zVarDataPtr+1 				; data high at +3
		sta 	(zBasicSP),y 	
		ply
		;
		;		Put the variable pointer as the first frame.
		;
		lda 	#(SMark_For << 4) + 3		
		jsr 	StackPushFrame 				; push on the stack with FOR marker.
		;
		;		TO <target>
		;
		lda 	#token_TO
		jsr 	CheckNextToken
		ldx 	#0 							; put in Mantissa, bottom
		jsr 	EvaluateExpression
		;
		;		STEP <step> if present, goes in 2nd slot.
		;
		#s_get 								; STEP present.
		ldx 	#XS_Size 					; X to second level
		cmp 	#token_STEP
		bne 	_CFOStep1
		#s_next 							; skip STEP
		jsr 	EvaluateExpressionX 		; get STEP value.
		bra 	_CFOHaveStep
_CFOStep1:				
		lda 	#0							; set step to integer 1.
		sta 	XS_Mantissa+1,x
		sta 	XS_Mantissa+2,x
		sta 	XS_Mantissa+3,x
		lda 	#1
		sta 	XS_Mantissa+0,x
		sta 	XS_Type,x
_CFOHaveStep:
		;
		;		Preconvert to the compatible type.
		;
		pla 								; restore variable type
		ldx 	#0
		cmp 	#token_Percent 				; do conversion to type
		beq 	_CFOInteger
		jsr 	FPUToFloat
		ldx 	#6
		jsr 	FPUToFloat
		bra 	_CFOEndConv
_CFOInteger:
		jsr 	FPUToInteger
		ldx 	#6
		jsr 	FPUToInteger
_CFOEndConv:
		jsr 	StackSavePosition 			; save the loop position at 1-5
		lda 	#(SMark_For << 4)+SourcePosSize
		jsr 	StackPushFrame 				; push the loop address frame.
		;
		;		Copy TARGET and STEP onto the stack and put that as a frame
		;		(3 in total)
		;
		phy
		ldy 	#0
_CFOCopy:
		lda 	XS_Mantissa+0,y
		iny
		sta 	(zBasicSP),y
		cpy 	#XS_Size*2
		bne 	_CFOCopy		
		ply
		lda 	#(SMark_For << 4)+(XS_Size*2)
		jsr 	StackPushFrame
		rts

_CFOError:
		jmp 	TypeError 					; wrong type.

; *******************************************************************************************
;
;									NEXT <var>[,var]
;
; *******************************************************************************************

Command_NEXT: ;; next
		nop
		lda 	#0 							; set variable data pointer+1 to zero
		sta 	zVarDataPtr+1 				; this means we don't check
		#s_get 								; variable ?
		cmp 	#0 							; EOL
		beq 	_CNextNoVariable
		cmp 	#$40
		bcs 	_CNextNoVariable
		;
		;		Followed by a variable, put address in zVarDataPtr for checking.
		;
		jsr 	VariableFind
		;
_CNextNoVariable:
		lda 	#(SMark_For << 4) 			; pop loop address frame
		jsr 	StackPopFrame
		lda 	#(SMark_For << 4) 			; pop STEP/TARGET frame.
		jsr 	StackPopFrame
		lda 	#(Smark_For << 4) 			; pop variable address frame.
		jsr 	StackPopFrame
		;
		;		Perhaps check the same variable used ?
		;
		lda 	zVarDataPtr+1 				; if zero, then no variable provided
		beq 	_CNextGetTarget 			; e.g. just NEXT not NEXT x

		phy 								; check addresses match.
		ldy 	#2
		lda 	(zBasicSP),y
		cmp 	zVarDataPtr
		bne 	_CNextWrong
		iny
		lda 	(zBasicSP),y
		cmp 	zVarDataPtr+1
		bne 	_CNextWrong
		ply

_CNextGetTarget:		
		;
		;		Get the target variable
		;
		phy
		ldy 	#1 							; restore variable type and data.
		lda 	(zBasicSP),y
		sta 	zVarType
		iny
		lda 	(zBasicSP),y
		sta 	zVarDataPtr
		iny
		lda 	(zBasicSP),y
		sta 	zVarDataPtr+1
		ldx 	#12
		jsr 	VariableGet 				; get that variable value into expr[2]
		;
		;		Get target and step back.
		;
		ldx 	#0 							; copy stacked Target/Step into expr[0] and [1]
		ldy 	#11
_CNXCopy:
		lda 	(zBasicSP),y 
		sta 	XS_Mantissa+0,x
		inx
		iny
		cpx 	#XS_Size*2
		bne 	_CNXCopy
		ply
		;
		;		Work out SGN(step)
		;
		ldx 	#6 							; point at expr[1] s
		jsr 	GetSignCurrent
		sta 	SignNext 					; save in temporary.
		;
		;		Add step (1) to variable value (2)
		;
		ldx 	#6 							; add them, however
		jsr 	BinaryOp_Add 				
		jsr 	VariableSet					; and write variable back.
		;
		;		Compare target and total.
		;
		ldx 	#0
		jsr 	CompareValues
		ora 	#0
		beq 	_CNXAgain 					; if true, then do it again.
		cmp 	SignNext 					; if sign different, then loop has finished.
		bne 	_CNXLoopDone
		;
		;		Restore frames (e.g. like they were pushed back) restoring
		;		position as you go past.
		;
_CNXAgain:
		lda 	#(SMark_For << 4) + 3		; re-stack variable address
		jsr 	StackPushFrame 				
		jsr 	StackRestorePosition 		; get restore position back, e.g. loop round.
		lda 	#(SMark_For << 4)+SourcePosSize
		jsr 	StackPushFrame
		lda 	#(SMark_For << 4)+(XS_Size*2)
		jsr 	StackPushFrame
_CNXExit:		
		rts
		;
		;		Loop complete, but check for ,<variable>
		;		
_CNXLoopDone:
		#s_get
		cmp 	#token_Comma 				; comma ?
		bne 	_CNXExit
		#s_next 							; skip comma
		jsr 	VariableFind 				; identify the variable
		jmp 	_CNextNoVariable 			; go back with variable pre-found

_CNextWrong:
		#Fatal	"Wrong Next Variable"