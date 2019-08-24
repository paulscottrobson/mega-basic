# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		testcreate.py
#		Purpose :	Create test programs
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
		print("Test # ",seed)
		random.seed(seed)
	#
	def getCount(self):
		return 200
	#
	def getInteger(self):
		return random.randint(-1000000,1000000)
	#
	def getFloat(self):
		return random.randint(-1000000000,1000000000)/1000.0
	#
	def format(self,n):
		if type(n) == float:
			if abs(n) > 10000000:
				return "{0:.8e}".format(n).replace("+","")
			return "{0:.8}".format(n)
		return str(n)
	#
	def arithmeticTest(self,useFloat = False,opList = "+-*/"):
		ok = False
		while not ok:
			ok = True
			operator = opList[random.randint(0,len(opList)-1)]
			n1 = self.getFloat() if useFloat else self.getInteger()
			n2 = self.getFloat() if useFloat else self.getInteger()
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
		if not useFloat:
			result = int(result)
		self.add('assert {0} {1} {2} = {3} '.format(self.format(n1),operator,self.format(n2),self.format(result)))
		
if __name__ == "__main__":
	bp = TestGenerator()
	for i in range(0,bp.getCount()):
		bp.arithmeticTest(True,"-")
	bp.add('Print "Passed.":stop')
	bp.export(sys.argv[1])
