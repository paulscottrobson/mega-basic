; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		let.asm
;		Purpose :	Assignment statement
;		Date :		25th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Command_LET: 	;; let
		jsr 	VariableFind 				; get reference to one variable.
		;
		lda 	#token_Equal  				; get equals
		jsr 	CheckNextToken 
		;
		lda 	zVarDataPtr 				; save variable info on stack
		pha
		lda 	zVarDataPtr+1
		pha
		lda 	zVarType
		pha
		jsr 	EvaluateExpression 			; evaluate the RHS, set X to zero.
		;
		pla 								; restore target variable information.
		sta 	zVarType
		pla
		sta 	zVarDataPtr+1
		pla
		sta 	zVarDataPtr
		;
		jsr 	VariableSet 				; set the value out.
		rts


