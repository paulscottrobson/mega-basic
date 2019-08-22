# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		basicprogram.py
#		Purpose :	Worker class : converts program to a byte sequence
#		Date :		19th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

from tokenise import *

# *******************************************************************************************
#
#								BASIC Program tokeniser
#
# *******************************************************************************************

class BasicProgram(object):
	def __init__(self):
		self.program = [ 0 ]													# program here
		self.tokeniser = Tokeniser()											# tokeniser worker.
		self.lastLineNumber = 1													# autogenerate lines.
	#
	#		Add a line of BASIC
	#
	def add(self,line,lineNumber = None):
		line = line.strip()														# lose spaces.
		lineNumber = lineNumber if lineNumber is not None else self.lastLineNumber+1
		assert lineNumber > self.lastLineNumber,"Line number sequencing error"
		self.lastLineNumber = lineNumber
		#
		code = self.tokeniser.tokenise(line)									# tokenise line.
		code.insert(0,len(code)+3)												# add offset.
		code.insert(1,lineNumber & 0xFF)										# add line#
		code.insert(2,lineNumber >> 8)
		#
		#print(lineNumber,line,",".join(["{0:02x}".format(c) for c in code]))
		#
		self.program = self.program[:-1] + code + [0] 							# add line in.
	#
	#		Save tokenised form out.
	#
	def save(self,fileName):
		h = open(fileName,"wb")
		h.write(bytes(self.program))
		h.close()
	#
	#		Export in assembler format.
	#
	def export(self):
		pos = 0
		while pos < len(self.program):											# while more to do.
			size = min(8,len(self.program)-pos)									# how big.
			data = self.program[pos:pos+size]									# chop bit out
			data = ",".join(["${0:02x}".format(n) for n in data])				# convert it
			print("\t.byte\t{0}".format(data))									# output it.
			pos = pos + size													# next chunk
		
if __name__ == "__main__":
	bp = BasicProgram()
	bp.add('assert "Hello,"+"world"+"!":rem hi !',10)
#	bp.add("a = a + 2")
#	bp.save("demo.bas")
	bp.export()
#
#		Basic Program Format:
#
#		+00		Total length (e.g. offset to next line), $00 marks the end
#		+01 	Line Number low (00 = no line number)
#		+02 	Line Number high.
#	
