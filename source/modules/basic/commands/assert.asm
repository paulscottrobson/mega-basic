; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		assert.asm
;		Purpose :	ASSET Command
;		Date :		23rd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************


ASSERT_Command: 	;; assert
		jsr 	EvaluateNumber 				; calculate thing being asserted
		lda 	XS_Mantissa,x 				; check if true (non-zero)
		ora 	XS_Mantissa+1,x
		ora 	XS_Mantissa+2,x
		ora 	XS_Mantissa+3,x
		beq 	_ASFail
		rts
_ASFail:#Fatal	"Assert"		

		