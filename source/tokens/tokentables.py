# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		tokenstables.py
#		Purpose :	Create the token tables.
#		Date :		19th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

from tokens import *
tokens = Tokens().get()

print("HeadTables: .macro")
#
#		Output useful constants first.
#
print("firstKeywordMinus = ${0:02x}".format(tokens["!!firstkeyminus"]))
print("firstKeywordPlus = ${0:02x}".format(tokens["!!firstkeyplus"]))
print("firstUnaryFunction = ${0:02x}".format(tokens["!!firstunary"]))
print("lastUnaryFunction = ${0:02x}".format(tokens["!!lastunary"]))

#
#		Get all the token names into executeLabel, and default to syntax error.
#
executeLabel = {}
keywords = []
for k in tokens.keys():
	if not k.startswith("!!"):
		executeLabel[k] = "NotImplemented"
		keywords.append(k)
keywords.sort(key = lambda x:tokens[x]["token"])		

#
#		TODO: Scan files,  looking for keywords, and give each extant a label.
#

#
#		Print jump vector table. May need modding for paging.
#
print(";\n;\tJump Vector Table\n;")
print("VectorTable:")
for k in keywords:
	print("\t.word {0:12} ; ${1:x} {2}".format(executeLabel[k],tokens[k]["token"],k))
print("NotImplemented:\n")
print("\t#error\n")
print('\t.text "Syntax Error",0')
#
#		Print binary precedence table.
#
print(";\n;\tBinary Precedence Level Table\n;")
print("BinaryPrecedence:")
for i in range(0x80,int(tokens["!!firstkeyplus"])):
	k = keywords[i-0x80]
	print("\t.byte {0}    ; ${1:x} {2}".format(tokens[k]["type"],tokens[k]["token"],k))
#
#		Print keyword lookup table.
#
print(";\n;\tKeyword Text\n;")
print("KeywordText:")
for k in keywords:
	kwb = [ord(x) for x in k.upper()]
	kwb[-1] = kwb[-1] | 0x80
	s = ",".join(["${0:02x}".format(x) for x in kwb])
	print("\t.byte {0:32} ; ${1:x} {2}".format(s,tokens[k]["token"],k))
print("\t.byte $00")
print("\t.endm")