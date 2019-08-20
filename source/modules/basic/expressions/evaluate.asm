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
		lda 	#0 							; start at precedence level 0.
		ldx 	#0 							; start with stack at 0.

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
		and 	#$3F 						; it's a constant 0-63
		sta 	XS_Mantissa,x 				; put into the mantissa space (32 bit integer)
		lda 	#0
		sta 	XS_Mantissa+1,x
		sta 	XS_Mantissa+2,x
		sta 	XS_Mantissa+3,x
		lda 	#1 							; set to type 1 (integer)
		sta 	XS_Type,x
		;
_EVCheckNextInteger:		
		#s_next 							; advance to next.
		#s_get
		eor 	#$40 						; 40-7F now 00-3F.
		cmp 	#$40 						; if not, we have an atom.
		bcs 	_EVCheckDecimal
		pha 								; save it.
		jsr 	EVShiftMantissaLeft6 		; shift the mantissa left 6.
		pla 		
		ora 	XS_Mantissa+0,x 			; put in lower 6 bits.
		sta 	XS_Mantissa+0,x
		bra 	_EVCheckNextInteger
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
_EVNotInteger:
		;
		; 	TODO: Check string, unary.
		;
		cmp 	#firstUnaryFunction 		; check for unary function
		bcc		EVESyntax
		cmp 	#lastUnaryFunction+1
		bcs 	EVESyntax
		jmp 	_EVUnaryFunction 		
;
;		At this point, there is a valid atom in XS_xxx,x *and* the precedence
;		level is on the first byte of the stack.
;		
_EVGotAtom:
		#exit

;
;		Discovered a variable.
;
_EVVariableHandler:
		nop		

;
;		Unary Function
;		
_EVUnaryFunction:
		nop


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
;			Decimal ($FD ll <chars>) follows - add this to the floating point sequence
;
; *******************************************************************************************

EVGetDecimal:
		nop
		;
		;		Copy .<characters> into a buffer (Num_Buffer)
		;		Set zGenPtr to point to that buffer,Y to 0.
		;		Call FPFromStr to convert/add it.
		;
		; 		Check decimal and exponents work.
		;
		;
		rts