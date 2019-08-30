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
		;		Identify the variable
		;
		jsr 	VariableFind 				; get reference to one variable.
		lda 	zVarType 					; obviously has to be integer/real.
		cmp 	#token_Dollar
		beq 	_CFOError
		;
		;		Skip the equals
		;
		lda 	#token_Equal  				; get equals
		jsr 	CheckNextToken 
		;
		;		Evaluate expression and copy in.
		;
		jsr 	FNXCopyVarDataToStackSpace 	; save the var reference data in BASIC stack.
		jsr 	EvaluateExpression 			; evaluate the RHS.
		jsr 	FNXGetVarDataFromStackSpace ; get var reference data back
		;
		ldx 	#0
		jsr 	VariableSet 				; set the value out.
		;
		;		Skip TO keyword
		;
		lda 	#token_TO 					; check the TO is present.
		jsr 	CheckNextToken
		;		
		;		Save position on the stack for the loop - evaluating the square bracket
		;		part of FOR I = 1 TO [9 STEP 3] each time round.
		;
		jsr 	StackSavePosition 			; goes in offset 1-5
		lda 	#(SMark_For << 4) + 3 + SourcePosSize		
		jsr 	StackPushFrame 				; push on the stack.
		;
		; 		Evaluate, but ignore the <n> STEP <n> part. This is purely syntax
		;
		jsr 	EvaluateExpression 			; the target value.
		#s_get
		cmp 	#token_STEP 				; is it STEP
		bne 	_CFOExit		
		#s_next 							; yes, skip it
		jsr 	EvaluateExpression 			; the STEP value.
_CFOExit:
		;
		;		Repair stack back, restore position, see if , follows.
		;
		rts

_CFOError:
		jmp 	TypeError 					; wrong type.

; *******************************************************************************************
;
;									NEXT <var>[,var]
;
; *******************************************************************************************

Command_NEXT: ;; next
		;
		;		Unpick the Stack Frame Push and put it back after the TO.
		;
		lda 	#(SMark_For << 4)
		jsr 	StackPopFrame 
		jsr 	StackRestorePosition
		;
		;		Check if there is a variable following.
		;
		#s_get
		cmp 	#$40
		bcs 	_CONNoNextVariable
		;
		;		Find variable and check it is the same one as the stack.
		;
		jsr 	VariableFind
		phy
		ldy 	#6
		lda 	(zBasicSP),y
		cmp 	zVarDataPtr
		bne 	_CONWrongNext
		iny
		lda 	(zBasicSP),y
		cmp 	zVarDataPtr+1
		bne 	_CONWrongNext
		;
_CONNoNextVariable:
		;
		;		Evaluate TO in bottom mantissa.
		;
		jsr 	EvaluateExpression 			; evaluate the 'TO' value at +0
		;
		;		Evaluate STEP in 2nd mantissa.
		;
		#s_get 								; next token. 
		ldx 	#XS_Size 					
		cmp 	#token_STEP 				; is it STEP ?
		beq 	_CONCalcStep 				; calculated step
		;
		lda 	#0							; set step to integer 1.
		sta 	XS_Mantissa+1,x
		sta 	XS_Mantissa+2,x
		sta 	XS_Mantissa+3,x
		lda 	#1
		sta 	XS_Mantissa+0,x
		sta 	XS_Type,x
		bra 	_CONHasStep
_CONCalcStep:
		#s_next 							; skip STEP
		jsr 	EvaluateExpressionX 		; and evaluate what the Step is
_CONHasStep:		
		jsr 	GetSignCurrent 				; get sign of STEP (in SGN() code)
		pha 								; save it (if STEP 0, we're going nowhere.)
		;
		;		Now get the actual value in 3rd mantissa slot.
		;
		jsr 	FNXGetVarDataFromStackSpace ; get var reference data back
		ldx 	#XS_Size*2
		jsr 	VariableGet 
		;
		;		So, we now have : <TARGET> <STEP> <VALUE>
		;
		ldx 	#XS_Size
		jsr 	BinaryOp_ADD 				; NewValue := STEP + VALUE
		;
		;		Now <TARGET> <STEP+VALUE>
		;	
		jsr 	VariableSet 				; save the result updating the variable.
		ldx 	#0 
		jsr 	CompareValues 				; compare Target-Counter, result in A.	
		plx 								; old compare value in X
		cmp 	#0 							; target-counter = 0 then continue.
		beq 	_CONExit
		sta 	zTemp1 						; save that comparison in A.
		cpx 	zTemp1 						; compare against target - counter sign.
		bne 	_CONEndLoop 				; if different loop ended.
_CONExit:
		lda 	#(SMark_For << 4) + 3 + SourcePosSize		
		jsr 	StackPushFrame 				; push on the stack.
		rts

_CONWrongNext:
		#Fatal	"Wrong next variable"

_CONEndLoop:
		nop

; *******************************************************************************************
;
;				Copy variable data address to/from its position on the stack.
;
; *******************************************************************************************

FNXCopyVarDataToStackSpace:
		phy
		ldy 	#6 				
		lda 	zVarDataPtr
		sta 	(zBasicSP),y
		iny
		lda 	zVarDataPtr+1
		sta 	(zBasicSP),y
		iny
		lda 	zVarType
		sta 	(zBasicSP),y
		ply
		rts

FNXGetVarDataFromStackSpace:
		phy
		ldy 	#6 				
		lda 	(zBasicSP),y
		sta 	zVarDataPtr
		iny
		lda 	(zBasicSP),y
		sta 	zVarDataPtr+1
		iny
		lda 	(zBasicSP),y
		sta 	zVarType
		ply
		rts
