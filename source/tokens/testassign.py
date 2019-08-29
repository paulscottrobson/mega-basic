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
		self.tokens = Tokens().get()
		self.initialiseName(name)
		#
		self.value = 0 if self.type != "$" else ''
	#
	def initialiseName(self,name = None):
		self.name = name if name is not None else self.createName()
		self.sname = self.name
		self.type = "#"
		if "#$%".find(self.name[-1]) >= 0:
			self.type = self.name[-1]
			self.sname = self.name[:-1]

	def createName(self):
		name = "".join([chr(random.randint(65,90)) for x in range(0,random.randint(1,4))])
		if len(name) > 1:
			name = name[0]+str(random.randint(0,9))+name[1:]
		return name.lower() + ["","#","%","$"][random.randint(0,3)]
	#
	def getNewValue(self):
		if self.type == '#':
			return random.randint(-10000,10000)/16.0
		if self.type == "%":
			return random.randint(-1000,1000)
		return self.createName()[:-1].upper()
	#
	def setupCode(self):
		return None
	#
	def checkCode(self):
		m = self.get()
		return 'assert {0}={1}'.format(m[0],m[1])
	#
	def get(self):
		return [self.name,self.quote(self.value)]
	#
	def update(self):
		self.value = self.getNewValue()
		m = self.get()
		return 'let {0}={1}'.format(m[0],m[1])
	#
	def quote(self,s):
		return '"'+s+'"' if isinstance(s,str) else str(s)

class Array(SingleVariable):
	def __init__(self,name = None):
		SingleVariable.__init__(self,name)
		self.arraySize = [random.randint(2,3)]
		defValue = 0 if self.type != "$" else ''
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
		return ":".join(['assert {0}({1})={2}'.format(self.name,c[0],self.quote(c[1])) for c in checks])
	#
	def update(self):
		v = self.getNewValue()
		n1 = random.randint(0,self.arraySize[0]-1)
		if len(self.arraySize) == 1:
			self.data[n1] = v
			return 'let {0}({1})={2}'.format(self.name,n1,self.quote(v))
		n2 = random.randint(0,self.arraySize[1]-1)
		self.data[n1][n2] = v
		return 'let {0}({1},{3})={2}'.format(self.name,n1,self.quote(v),n2)

	#
class TestGenerator(BasicProgram):
	def __init__(self,size,seed = None):
		BasicProgram.__init__(self)
		if seed is None:
			random.seed()
			seed = random.randint(0,999999)
		print("Assign Test # ",seed)
		random.seed(seed)
		self.variables = {}		
		for i in range(0,size):
			ok = False
			while not ok:
				sv = SingleVariable()
				ok = sv.sname not in self.variables 
			self.variables[sv.sname] = sv
		for i in range(0,size >> 3):
			ok = False
			while not ok:
				sv = Array()
				ok = sv.sname not in self.variables 
			self.variables[sv.sname] = sv
		self.keys = [x for x in self.variables.keys()]

	def update(self):
		k = self.keys[random.randint(0,len(self.keys)-1)]
		self.add(self.variables[k].update())

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
	bp = TestGenerator(100) # ,261102
	bp.add("list")
	bp.preamble()
	for i in range(0,200):
		bp.update()
	bp.postscript()
	bp.add('Print "Passed Assignment.":stop')
	bp.export(sys.argv[1])
