; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		stack.inc
;		Purpose :	Stack Marker IDs (0-15)
;		Date :		23rd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

SourcePosSize   =   5 							; Source position stack space needed.

SMark_Gosub 	= 	0 							; 0 is GOSUB/RETURN.
SMark_Repeat 	= 	1 							; 1 is REPEAT/UNTIL.
SMark_While 	= 	2 							; 2 is WHILE/WEND.