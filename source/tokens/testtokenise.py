# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		testtokenise.py
#		Purpose :	Create test and result for automatic testing.
#		Date :		3rd September 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

from tokens import *
from tokenise import *
import random,sys

def getAlphaNum():
	return"0123456789abcdefghijklmnopqrstuvwxyz"[random.randint(0,35)]

def getWord():
	return "".join([getAlphaNum() for x in range(0,random.randint(0,4))])

def isalnum(c):
	return (c.lower()>='a' and c.lower()<='z') or (c >= '0' and c <= '9')

def getComponent():
	n = random.randint(0,2)
	if n == 0:
		s = str(random.randint(0,99999))
		if random.randint(0,3) == 0:
			s = s + "."+str(random.randint(0,999))
			if random.randint(0,1) == 0:
				s = s + "e"+str(random.randint(-20,20))
		return s
	if n == 1:
		token = "!"
		while token.startswith("!"):
			token = [x for x in Tokens().get().keys()]
			token = token[random.randint(0,len(token)-1)]
		if token[-1] >= 'a' and token[-1] <= 'z':
			if random.randint(0,2) == 0:
				token = token+"".join([getAlphaNum() for x in range(0,random.randint(1,3))])
		return token
	if n == 2:
		return '"'+getWord()+'"'
	if n == 3:
		return "rem "+getWord()+":"

random.seed()
s = random.randint(0,999999)
sys.stderr.write("Tokeniser test #{0}\n".format(s))
random.seed(s)
src = " "
while len(src) < 128:
	nc = getComponent()
	if isalnum(src[-1]) and isalnum(nc[0]):
		nc = " "+nc
	src = src + nc

tokens = Tokeniser().tokenise(src.strip())
tokens = ",".join(["${0:02x}".format(c) for c in tokens])

s = """
TokeniseTestIn:		
		.text '{0}',0
TokeniseTestOut:
		.byte 	{1}
TokeniseTestOutEnd:
""".format(src,tokens)

print(s)
sys.stderr.write(src)
