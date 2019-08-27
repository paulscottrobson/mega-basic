# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		testassign.py
#		Purpose :	Test programs for assignment and arrays
#		Date :		27th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

from basicprogram import *
import random,sys

class SingleVariable(object):
	def __init__(self,name = None):
		self.name = name if name is not None else self.createName()
		self.sname = self.name
		self.type = "#"
		if "#$%".find(self.name[-1]) >= 0:
			self.type = self.name[-1]
			self.sname = self.name[:-1]
		self.value = 0 if self.type != "$" else '""'
	#
	def createName(self):
		name = "".join([chr(random.randint(65,90)) for x in range(0,random.randint(1,4))])
		return name.lower() + ["","#","%","$"][random.randint(0,3)]
	#
	def setupCode(self):
		return None
	#
	def checkCode(self):
		return 'assert {0}={1}'.format(self.name,self.value)
	#
	def get(self):
		return [self.name,self.value]

class Array(SingleVariable):
	def __init__(self,name = None):
		SingleVariable.__init__(self,name)
		self.arraySize = [random.randint(2,3)]
		defValue = 0 if self.type != "$" else '""'
		self.data = [ defValue ] * self.arraySize[0]
		if random.randint(0,3) == 0:
			self.arraySize.append(random.randint(2,3))
			self.data = []
			for i in range(0,self.arraySize[0]):
				self.data.append([ defValue ] *self.arraySize[1])
	#
	def setupCode(self):
		return 'dim {0}({1})'.format(self.name,",".join([str(x-1) for x in self.arraySize]))
	#
	def checkCode(self):
		checks = []	
		for i in range(0,self.arraySize[0]):
			if len(self.arraySize) == 1:
				checks.append([str(i),self.data[i]])
			else:
				for j in range(0,self.arraySize[1]):
					checks.append([str(i)+","+str(j),self.data[i][j]])
		return ":".join(['assert {0}({1})={2}'.format(self.name,c[0],c[1]) for c in checks])

	#
class TestGenerator(BasicProgram):
	def __init__(self,seed = 42):
		BasicProgram.__init__(self)
		if seed is None:
			random.seed()
			seed = random.randint(0,999999)
		print("Test # ",seed)
		random.seed(seed)
		self.variables = {}		
		for i in range(0,4):
			ok = False
			while not ok:
				sv = SingleVariable()
				ok = sv.sname not in self.variables 
			self.variables[sv.sname] = sv
		for i in range(0,2):
			ok = False
			while not ok:
				sv = Array()
				ok = sv.sname not in self.variables 
			self.variables[sv.sname] = sv


	def preamble(self):
		for v in self.variables.keys():
			code = self.variables[v].setupCode()
			if code is not None:
				self.add(code)

	def postscript(self):
		for v in self.variables.keys():
			code = self.variables[v].checkCode()
			if code is not None:
				self.add(code)

if __name__ == "__main__":
	bp = TestGenerator()
	bp.preamble()
	bp.postscript()
	bp.add('Print "Passed Assignment.":stop')
	bp.export(sys.argv[1])
