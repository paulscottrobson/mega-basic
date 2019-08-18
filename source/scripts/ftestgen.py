# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		ftestgen.py
#		Purpose :	Floating Point Script test generator.
#		Date :		15th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random,sys
from fscript import *

class FPTest(object):
	def __init__(self,seed = random.randint(0,999999)):
		random.seed(seed)
		print("; Using seed {0}".format(seed))
		self.target = FScriptCompiler(sys.stdout)
		self.target.integer(99999)
		self.setOperators()
	#
	def setOperators(self,opList = "+-*/~"):
		self.operators = opList
	#
	def generateTest(self,n):
		operator = self.operators[random.randint(0,len(self.operators)-1)]
		result = None
		while result is None:
			n1 = float(self.generateValue())
			n2 = float(self.generateValue())
			if random.randint(0,20) == 0:
				n1 = n2
			result = self.calculate(operator,n1,n2)
		self.target.float(n1) 					# push n1
		self.target.float(n2)					# push n2
		self.target.command(operator) 			# calculate
		self.target.float(result) 				# push result
		self.target.command("=")				# check equals.	
	#
	def calculate(self,operator,n1,n2):
		if operator == "+":
			return n1+n2
		elif operator == "-":
			return n1-n2
		elif operator == "*":
			return n1*n2
		elif operator == "/":
			return n1/n2 if n2 != 0 else None
		elif operator == "~":
			if n1 == n2:
				return 0
			else:
				return -1 if n1 < n2 else 1
		else:
			assert False
	#
	def generateValue(self):
		sel = random.randint(0,3)
		if sel == 0:
			return random.randint(-20,20) if random.randint(0,8) > 0 else 0
		if sel == 1:
			return random.randint(-1000000,10000000)/1000000.0
		if sel == 2:
			pw = random.randint(10,50) * self.randomSign()
			mn = (0.1+random.randint(0,900000)/1000000) * self.randomSign()
			return pow(2.0,pw)*mn
		return random.randint(-100000,100000)/100.0
	#
	def randomSign(self):
		return -1 if random.randint(0,1) == 0 else 1

if __name__ == "__main__":
	test = FPTest()
	#test.setOperators("-")
	for i in range(0,200):
		test.generateTest(i)
	test.target.integer(99999)
