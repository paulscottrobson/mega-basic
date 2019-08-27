; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		dim.asm
;		Purpose :	DIM Command
;		Date :		27th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************


Command_DIM: 	;; dim
		phy 								; save Y which is the start of the name.
		jsr 	VariableExtract 			; get the identifier
		lda 	Var_Type 					; check it is an array
		and 	#1 
		cmp 	#(token_DollarLParen & 1)
		bne 	_CDIError 
		;
		lda 	#0 							; reset the DIM index. The dimensions are
		sta 	UsrArrayIdx 				; built up here and copied in case we autodim
		;
_CDIGetDimension:
		lda 	UsrArrayIdx 				; done too many ?
		cmp 	#ArrayMaxDim*2 				
		beq 	_CDIError
		;
		jsr 	EvaluateExpression 			; evaluate an index size
		lda 	XS_Mantissa+1 				; check in range 0-7FFF
		and 	#$80
		ora 	XS_Mantissa+2
		ora 	XS_Mantissa+3 
		bne 	_CDIError
		;
		ldx 	UsrArrayIdx 				; copy into the array table.
		clc 								; add 1 - max index => size.
		lda 	XS_Mantissa+0
		adc 	#1
		sta 	UsrArrayDef+0,x
		lda 	XS_Mantissa+1
		adc 	#0
		sta 	UsrArrayDef+1,x
		bmi 	_CDIError 					; could be dim a(32767)
		;
		inx 								; bump index.
		inx
		stx 	UsrArrayIdx

		#s_get 								; get next character
		#s_next
		cmp 	#token_Comma 				; comma, do another dimension
		beq 	_CDIGetDimension
		#s_prev 							; undo the get,		
		jsr 	CheckNextRParen 			; closing ) present ?
		;
		;
		ldx 	UsrArrayIdx 				; copy USR array to default
		lda 	#$FF 						; put end marker in ArrayDef
		sta 	ArrayDef+1,x
_CDICopy:
		lda 	UsrArrayDef,x
		sta 	ArrayDef,x
		dex
		bpl 	_CDICopy
		;
		pla									; position of array identifier
		phy 								; save end position.
		tay 								; point to identifier
		jsr 	VariableExtract 			; get the identifier
		jsr 	VariableLocate 				; check if it exists already.
		bcs 	_CDIError
		jsr 	VariableCreate 				; create it using the current ArrayDef
		ply 								; restore code position
		;		
		#s_get 								; get next character
		#s_next
		cmp 	#token_Comma 				; comma, do another DIM
		beq 	Command_DIM
		#s_prev 							; undo it.
		rts

_CDIError:		
		#Fatal 	"Bad DIM"
_CDISyntax:
		jmp 	SyntaxError		
