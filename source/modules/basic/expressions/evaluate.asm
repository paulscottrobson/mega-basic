; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		evaluate.asm
;		Purpose :	Expression Evaluation.
;		Date :		20th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

EVESyntax:
		jmp 	SyntaxError

; *******************************************************************************************
;
;									Evaluate expression
;
; *******************************************************************************************

EvaluateExpression:
		ldx 	#0 							; start with stack at 0.
EvaluateExpressionX:		
		lda 	#0 							; start at precedence level 0.
EvaluateExpressionXA:
		pha 								; save precedence on stack.
		;
		#s_get 								; look at next ?
		beq 	EVESyntax 					; end of line, syntax error.
		cmp 	#26+1 						; is it A-Z ?
		bcs 	_EVNotVariable
		jmp 	_EVVariableHandler 			; if so, go to the variable handler.
		;
_EVNotVariable:		
		cmp 	#$40 						; up to $40, syntax error.
		bcc 	EVESyntax
		cmp 	#$80 						; $40-$7F not integer
		bcs 	_EVNotInteger 
;
;		Found an integer marker $40-$7F, so shift the integer into the current
;		expression stack level.
;
		jsr 	EvaluateGetInteger 	
;
;		Check if it is followed by a decimal/exponential code. If so
;		convert to the appropriate float.
;
_EVCheckDecimal:
		#s_get 								; what's next ?
		cmp 	#$FD 						; decimal ?
		bne 	_EVGotAtom 					; no, get atom.
_EVIsDecimal:		
		jsr 	EVGetDecimal 				; extend to the decimal part.
		bra 	_EVGotAtom 					; and continue to got atom.
;
;		At this point, there is a valid atom in XS_xxx,x *and* the precedence
;		level is on the first byte of the stack.
;		
_EVGotAtom:
		#s_get 								; get the next token.
		bpl 	_EVExitDrop 				; must be a token.
		cmp 	#firstKeywordPlus  			; check it's in the binary token range (they're first)
		bcs 	_EVExitDrop
		pla 								; get current precedence
		sta 	zGenPtr 					; save in zGenPtr as temp.
		;
		phx 								; save X
		#s_get 								; get the binary token
		tax 								; put in X
		lda 	BinaryPrecedence-$80,x 		; read the binary precedence.
		sta 	zGenPtr+1 					; save it.
		plx 								; restore X
		cmp 	zGenPtr 					; compared against the current precedence
		bcc 	_EVExit 					; exit if too low.
		beq 	_EVExit 					; exit if equals
		;
		lda 	zGenPtr 					; push precedence
		pha
		#s_get 								; get and push binary token.
		pha 
		#s_next 							; go to next.
		;
		phx 								; save current position
		inx6 							 	; advance to next
		lda 	zGenPtr+1 					; get the precedence of the operator in A.
		jsr 	EvaluateExpressionXA 		; do the RHS.
		plx 								; restore X
		;
		pla 								; get the binary operator in A.
_EVCallA:		
		phx 								; save X again
		asl 	a 							; double, lose the MSB.
		tax									; put in X
		lda 	VectorTable,x 				; copy address into zGenPtr
		sta 	LocalVector+1
		lda 	VectorTable+1,x
		sta 	LocalVector+2
		plx 								; restore X
		jsr 	EVCallLocalVector
		bra 	_EVGotAtom 					; and loop back.
		;
_EVExitDrop:
		pla
_EVExit:
		rts		
;
;		Not an integer: check unary operators, string , unary functions and parenthesis
;
_EVNotInteger:
		#s_next 							; skip over token.
		cmp 	#token_minus 				; is it unary minus ?
		bne 	_EVNotMinus
		;
		;		Unary minus
		;	
		jsr 	EvaluateGetAtomX 			; get a numeric value into X.
		lda 	XS_Type,x 					; get type
		and 	#15 						; if type bits zero, it's float.
		beq 	_EVMinusFloat
		jsr 	IntegerNegateAlways 		; negation
		bra 	_EVGotAtom 					; and go back.
;
_EVMinusFloat:
		lda 	XS_Type,x 					; invert the sign bit.	
		eor 	#$80
		sta 	XS_Type,x
		bra 	_EVGotAtom
;
_EVNotMinus:
		cmp 	#token_lparen 				; is it left parenthesis
		bne 	_EVNotParenthesis
		;
		;		Parenthesis.
		;
		jsr 	EvaluateExpressionX 		; full evaluate at level x.
		#s_get								; get next character
		#s_next
		cmp 	#token_rparen 				; okay if right bracket.
		beq 	_EVGotAtom
		#Fatal	"Missing )"

_EVNotParenthesis:		
		cmp 	#token_not 					; is it not ?
		bne 	_EVNotNot 
		;
		;		Logical Not (e.g. integer one's complement)
		;		
		jsr 	EvaluateGetAtomX 			; get expression in parenthesis.
		.if 	hasFloat=1
		jsr 	FPUToInteger 				; make it an integer - if possible.
		.endif
		jsr 	NotInteger 					; do the not calculation
		jmp 	_EVGotAtom
		;
_EVNotNot:
		cmp 	#$FE 
		bne 	_EVNotString		
		;
		;		Quoted string.
		;
		jsr 	CreateTempStringCopy 		; copy of string in code in temporary memory.
		lda 	zTempStr 					; copy address of string into mantissa
		sta 	XS_Mantissa+0,x
		lda 	zTempStr+1
		sta 	XS_Mantissa+1,x
		lda 	#2 							; set to type 2 (e.g. string)
		sta 	XS_Type,x
		jmp 	_EVGotAtom
		;
_EVNotString:	
		cmp 	#firstUnaryFunction
		bcc 	_EVBadElement
		cmp 	#lastUnaryFunction+1
		bcc 	_EVUnaryFunction		
_EVBadElement:
		jmp 	SyntaxError
_EVUnaryFunction:		
		jmp 	_EVCallA
		;
		;		Found a variable
		;
_EVVariableHandler:
		jsr 	VariableFind 				; locate a variable
		jsr 	VariableGet 				; copy into memory.
		jmp 	_EVGotAtom 					; and go round.

EVCallLocalVector:
		jmp 	(LocalVector+1)

; *******************************************************************************************
;
;							Shift the mantissa left 6 bits
;
; *******************************************************************************************

EVShiftMantissaLeft6:
		lda 	XS_Mantissa+3,x 				; copy up, using exponent as a temp
		sta 	XS_Exponent,x
		lda 	XS_Mantissa+2,x
		sta 	XS_Mantissa+3,x
		lda 	XS_Mantissa+1,x
		sta 	XS_Mantissa+2,x
		lda 	XS_Mantissa+0,x
		sta 	XS_Mantissa+1,x
		lda 	#0
		sta 	XS_Mantissa+0,x
		jsr 	_EVSMLShift 					; call it here to do it twice
_EVSMLShift:		
		lsr 	XS_Exponent,x
		ror 	XS_Mantissa+3,x
		ror 	XS_Mantissa+2,x
		ror 	XS_Mantissa+1,x
		ror 	XS_Mantissa+0,x
		rts

; *******************************************************************************************
;
;									Get an integer into mantissa,x
;
; *******************************************************************************************

EvaluateGetInteger:
		#s_get
		and 	#$3F 						; it's a constant 0-63
		sta 	XS_Mantissa,x 				; put into the mantissa space (32 bit integer)
		lda 	#0
		sta 	XS_Mantissa+1,x
		sta 	XS_Mantissa+2,x
		sta 	XS_Mantissa+3,x
		inc 	a 							; set to type 1 (integer)
		sta 	XS_Type,x
		;
_EVCheckNextInteger:		
		#s_next 							; advance to next.
		#s_get
		eor 	#$40 						; 40-7F now 00-3F.
		cmp 	#$40 						; if not, we have an atom.
		bcs 	_EVEndInteger
		pha 								; save it.
		jsr 	EVShiftMantissaLeft6 		; shift the mantissa left 6.
		pla 		
		ora 	XS_Mantissa+0,x 			; put in lower 6 bits.
		sta 	XS_Mantissa+0,x
		bra 	_EVCheckNextInteger
_EVEndInteger:
		rts
		
; *******************************************************************************************
;
;			Decimal ($FD ll <chars>) follows - add this to the floating point sequence
;
; *******************************************************************************************

EVGetDecimal:
		.if hasFloat = 1
		lda 	#'.'							; put DP in NUM_Buffer
		sta 	Num_Buffer
		phx
		#s_next 								; move forward.
		#s_get 									; get the total length.
		#s_next 								; skip over that
		dec 	a								; convert to a string length.
		dec 	a
		ldx 	#1 								; offset in X.
_EVGDCopy:				
		pha 									; save count
		#s_get 									; get and save character
		sta 	Num_Buffer,x
		inx 									; forward ....
		#s_next
		pla 									; get count
		dec 	a 								; until zero
		bne 	_EVGDCopy 
		sta 	Num_Buffer,x 					; make string ASCIIZ.
		plx 									; restore X

		lda 	#Num_Buffer & $FF 				; set zGenPtr
		sta 	zGenPtr
		lda 	#Num_Buffer >> 8
		sta 	zGenPtr+1
		phy 									; save Y
		ldy 	#0 								; start position
		jsr 	FPFromString 					; convert current 
		ply 									; restore Y
		rts
		.else
		jmp 	SyntaxError
		.endif

; *******************************************************************************************
;
;										Logical NOT
;
; *******************************************************************************************

NotInteger:
		lda 	XS_Mantissa+0,x
		eor 	#$FF
		sta 	XS_Mantissa+0,x
		lda 	XS_Mantissa+1,x
		eor 	#$FF
		sta 	XS_Mantissa+1,x
		lda 	XS_Mantissa+2,x
		eor 	#$FF
		sta 	XS_Mantissa+2,x
		lda 	XS_Mantissa+3,x
		eor 	#$FF
		sta 	XS_Mantissa+3,x
		rts

; *******************************************************************************************
;
;										Get atomic value
;
; *******************************************************************************************

EvaluateGetAtom:
		ldx 	#0 								; start at the bottom :)
EvaluateGetAtomX:
		lda 	#8 								; very high precedence so no binary operations.
		jsr 	EvaluateExpressionXA
		lda 	XS_Type,x 						; check type is 0 (float) 1 (integer)
		and 	#15
		cmp 	#2
		bcs 	EvaluateType
		rts
		;
EvaluateType:
		jmp 	TypeError

; *******************************************************************************************
;
;										Get numeric value
;
; *******************************************************************************************

EvaluateNumber:	
		ldx 	#0
EvaluateNumberX:
		jsr 	EvaluateExpressionX
		lda 	XS_Type,x 						; check type is 0/1
		and 	#15 					
		cmp 	#2
		bcs 	EvaluateType
		rts

EvaluateInteger:
		ldx 	#0
EvaluateIntegerX:
		jsr 	EvaluateNumberX
		.if 	hasFloat=1
		jsr 	FPUToInteger
		.endif
		rts
				
; *******************************************************************************************
;
;										Get string value
;
; *******************************************************************************************

EvaluateString:	
		ldx 	#0
EvaluateStringX:
		jsr 	EvaluateExpressionX
		lda 	XS_Type,x 						; check type is 2
		and 	#15 					
		cmp 	#2
		bne 	EvaluateType
		lda 	XS_Mantissa,x 					; copy to zGenPtr
		sta 	zGenPtr
		lda 	XS_Mantissa+1,x
		sta 	zGenPtr+1
		rts
		
