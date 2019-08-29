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
import sys

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
		if lineNumber is None:
			lineNumber = int((self.lastLineNumber+10	)/10)*10
		assert lineNumber > self.lastLineNumber,"Line number sequencing error"
		self.lastLineNumber = lineNumber
		#
		code = self.tokeniser.tokenise(line)									# tokenise line.
		code.insert(0,len(code)+3)												# add offset.
		code.insert(1,lineNumber & 0xFF)										# add line#
		code.insert(2,lineNumber >> 8)
		#
		#print(lineNumber,line)
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
	def export(self,file):
		h = open(file,"w")
		pos = 0
		while pos < len(self.program):											# while more to do.
			size = min(8,len(self.program)-pos)									# how big.
			data = self.program[pos:pos+size]									# chop bit out
			data = ",".join(["${0:02x}".format(n) for n in data])				# convert it
			h.write("\t.byte\t{0}\n".format(data))								# output it.
			pos = pos + size													# next chunk
		h.close()

if __name__ == "__main__":
	bp = BasicProgram()
#	bp.add('list:stop')
	bp.add('print "Hello !"')
	bp.add('X = 6')
	bp.add('while X > 0')
	bp.add('Y = 0')
	bp.add('repeat')
	bp.add('PRINT X,Y:Y = Y + 1')
	bp.add('until Y = 3:X=X-1:wend')
	bp.add('print "End."')
	bp.add('stop')
	bp.export(sys.argv[1])
#
#		Basic Program Format:
#
#		+00		Total length (e.g. offset to next line), $00 marks the end
#		+01 	Line Number low (00 = no line number)
#		+02 	Line Number high.
#	
