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

SMark_Gosub 	= 	1 							; 0 is GOSUB/RETURN.
SMark_Repeat 	= 	2 							; 1 is REPEAT/UNTIL.
SMark_While 	= 	3 							; 2 is WHILE/WEND.
SMark_If 		= 	4 							; 3 is IF/ENDIF
SMark_For 		= 	5 							; 4 is FOR/NEXT