; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		checks.asm
;		Purpose :	Check token code
;		Date :		22nd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									Does token match A ?
;
; *******************************************************************************************

CheckNextToken:
		#s_cmp 								; found ?
		bne 	CTFail 						; no, then fail
		#s_next 							; bump
		rts

CTFail:#Fatal	"Missing token"

; *******************************************************************************************
;
;									Standard token checks
;
; *******************************************************************************************

directcheck: .macro
		#s_get 								; get character
		cmp 	#\1 						; does it match
		bne 	CTFail 						; fail if not
		#s_next 							; skip it.
		rts
		.endm

CheckNextRParen:
		#directcheck 	token_rparen

CheckNextComma:
		#directcheck 	token_comma

