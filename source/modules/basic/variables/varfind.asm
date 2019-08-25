; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		varfind.asm
;		Purpose :	Examine current hash table chain for a variable.
;		Date :		20th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;		Locate variable in hash table chain. CC if failed, CS and pointers set up if
;		succeeded.
;
; *******************************************************************************************

VariableLocate:
		clc
		rts

