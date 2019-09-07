# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		testmath.py
#		Purpose :	Create test programs for binary/unary arithmetic/strings.	
#		Date :		24th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

from basicprogram import *
import random,sys

class TestGenerator(BasicProgram):
	def __init__(self,seed = None):
		BasicProgram.__init__(self)
		if seed is None:
			random.seed()
			seed = random.randint(0,999999)
		print("Math Test # ",seed)
		random.seed(seed)
	#
	#		Number of iterations of test loop
	#
	def getCount(self):
		return 70
	#
	#		Create test values
	#
	def getInteger(self):
		if random.randint(0,10) == 0:
			return 0
		return random.randint(-1000000,1000000)
	#
	def getFloat(self):
		if random.randint(0,5) == 0:
			return 0.0
		return random.randint(-1000000000,1000000000)/1000.0
	#
	def getString(self):
		return "".join([chr(random.randint(0,25)+97) for x in range(random.randint(0,10))])
	#
	#		Format test values (cannot handle very long decimals at present)
	#
	def format(self,n):
		if type(n) == float:
			if abs(n) > 10000000:
				return "{0:.8e}".format(n).replace("+","")
			return "{0:.8}".format(n)
		return str(n)
	#
	#		Testing + - * /
	#
	def arithmeticTest(self,useFloat = False,opList = None):
		ok = False
		if opList is None:
			opList = "+,-,*,/,<,=,>,>=,<=,<>".split(",")
		while not ok:
			ok = True
			operator = opList[random.randint(0,len(opList)-1)]
			n1 = self.getFloat() if useFloat else self.getInteger()
			n2 = self.getFloat() if useFloat else self.getInteger()
			if random.randint(0,20) == 0:
				n1 = n2
			if n2 == 0 and operator == "/":
				ok = False
			if operator == "*" and abs(n1*n2) > 0x7FFFFFFF and (not useFloat):
				ok = False
		if operator == "+":
			result = n1 + n2
		elif operator == "-":
			result = n1 - n2
		elif operator == "*":
			result = n1 * n2
		elif operator == "/":
			result = n1 / n2
		elif operator == ">":
			result = -1 if n1 > n2 else 0
		elif operator == "<":
			result = -1 if n1 < n2 else 0
		elif operator == "=":
			result = -1 if n1 == n2 else 0
		elif operator == ">=":
			result = -1 if n1 >= n2 else 0
		elif operator == "<=":
			result = -1 if n1 <= n2 else 0
		elif operator == "<>":
			result = -1 if n1 != n2 else 0

		if operator != "/" and not useFloat:
			result = int(result)

		self.add('assert ({0} {1} {2}) = {3} '.format(self.format(n1),operator,self.format(n2),self.format(result)))
	#	
	#		Testing and or xor
	#
	def logicalTest(self):
		n1 = self.getInteger()
		n2 = self.getInteger()
		operator = ["and","or","xor"][random.randint(0,2)]
		if operator == "and":
			result = n1 & n2
		if operator == "or":
			result = n1 | n2
		if operator == "xor":
			result = n1 ^ n2
		self.add('assert ({0} {2} {1}) = {3} '.format(n1,n2,operator,result))
	#
	#		Implementation of SGN
	#
	def sgn(self,n):
		if n != 0:
			n = -1 if n < 0 else 1
		return n
	#
	#		Test numeric unary functions, val, str$ and not.
	#
	def numberTest(self,n):
		n = n % 5
		n1 = self.getInteger()
		if n == 0:
			self.add("assert (abs({0})) = {1}".format(n1,abs(n1)))
		if n == 1:
			self.add("assert (sgn({0})) = {1}".format(n1,self.sgn(n1)))
		if n == 2:
			n2 = self.getInteger()
			if n2 != 0:
				result = abs(n1) % abs(n2)
				self.add("assert (mod({0},{1})) = {2}".format(n1,n2,result))
		if n == 3:
			self.add("assert (not {0}) = {1}".format(n1,-n1-1))
		if n == 4:
			if random.randint(0,1):
				n1 = self.getFloat()
			self.add("assert (val(str$({0}))) = {0}".format(self.format(n1)))
	#
	#		Test string functions.
	#
	def stringTest(self,n):
		s1 = self.getString()
		p1 = random.randint(1,10)
		p2 = random.randint(0,10)
		n = n % 9
		if n == 0:
			self.add('assert (left$("{0}",{1})) = "{2}"'.format(s1,p2,s1[:p2]))
		if n == 1:
			self.add('assert (right$("{0}",{1})) = "{2}"'.format(s1,p2,s1[-p2:] if p2 != 0 else ""))
		if n == 2:			
			self.add('assert (mid$("{0}",{1},{2})) = "{3}"'.format(s1,p1,p2,s1[p1-1:p1+p2-1]))
		if n == 3:
			self.add('assert (len("{0}")) = {1}'.format(s1,len(s1)))
		if n == 4 and s1 != "":
			self.add('assert (asc("{0}")) = {1}'.format(s1,ord(s1[0])))
		if n == 5:
			n1 = random.randint(32,126)
			self.add('assert (chr$({0})) = "{1}"'.format(n1,chr(n1)))
		if n == 6:
			n1 = random.randint(0,20)
			self.add('assert (spc({0})) = "{1}"'.format(n1," " * n1))
		if n == 7:
			n1 = abs(self.getInteger())
			self.add('assert (hex$({0})) = "{1}"'.format(n1,"{0:X}".format(n1)))
		if n == 8:
			n1 = abs(self.getInteger())
			self.add('assert (dec("{1}")) = {0}'.format(n1,"{0:X}".format(n1)))


if __name__ == "__main__":
	bp = TestGenerator(42)
	for i in range(0,bp.getCount()*0+1):
		bp.arithmeticTest(True)
		bp.arithmeticTest(False)
		bp.logicalTest()
		bp.numberTest(i)
		bp.stringTest(i)

	bp.add('Print "Passed Arithmetic,Logical,Unary.":end')
	bp.export(sys.argv[1])
