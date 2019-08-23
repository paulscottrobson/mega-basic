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

import sys
from tokens import *

tokens = Tokens().get()
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
#		Scan files,  looking for keywords, and give each extant a label.
#
files = [x.strip() for x in open(".."+os.sep+"_files.lst").read(-1).strip().split("::") if x.strip() != ""]
for fName in files:
	for l in open(".."+os.sep+fName).readlines():
		if l.find(";;") >= 0:
			m = re.match("^([A-Za-z0-9\\_]+)\\:\\s*\\;\\;\\s*(.*)\\s*$",l.strip())
			assert m is not None,"Bad line "+l+" in "+fName
			lbl = m.group(2).lower().strip()
			assert lbl in tokens,"Code found for non token "+lbl
			assert executeLabel[lbl] == "NotImplemented","Duplicate code "+lbl
			executeLabel[lbl] = m.group(1).strip()
#
#		Print jump vector table. May need modding for paging.
#
print(";\n;\tJump Vector Table\n;")
print("VectorTable:")
for k in keywords:
	print("\t.word {0:20} & $FFFF ; ${1:x} {2}".format(executeLabel[k],tokens[k]["token"],k))
print("NotImplemented:\n")
print('\t#fatal "Not implemented"\n')
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
#
#		Generate token constants
#
for k in keywords:
	name = k.lower().strip()
	if re.match("^[a-z]+\\($",name) is not None:
		name = name[:-1]	
	name = name.replace("=","equal").replace(">","greater").replace("<","less")
	name = name.replace("+","plus").replace("-","minus").replace("*","star").replace("/","slash")
	name = name.replace("^","hat").replace("(","lparen").replace(")","rparen")
	name = name.replace("$","dollar").replace("#","hash").replace("%","percent").replace(",","comma")
	name = name.replace(":","colon").replace(";","semicolon")
	assert re.match("^[a-z\\_]+$",name) is not None,"Token convert "+name
	print("token_{0} = ${1:x}".format(name,tokens[k]["token"]))