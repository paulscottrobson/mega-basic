# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		fscript.py
#		Purpose :	Floating Point Script Compiler. Like a simple RPN calculator.
#		Date :		15th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import sys

class FScriptCompiler(object):
	def __init__(self,handle = sys.stdout):
		self.tgt = handle
	#
	def integer(self,n):
		n1 = int(n) & 0xFFFFFFFF 										# convert to 32 bit.
		self.tgt.write("\t.byte 	1	; *** Load Integer {0} ***\n".format(n))
		self.tgt.write("\t.dword 	${0:x}\n".format(n1))
		self.tgt.write("\t.byte 	0,$01\n")
	#
	def float(self,f):
		szByte = 0 														# defaults
		mantissa = 0
		exponent = 0x80
		fOrg = f
		if f == 0.0:													# convert to float format.
			szByte = 0x40												# zero
		else:
			szByte = 0x00 												# non-zero
			if f < 0:
				f = abs(f)
				szByte = 0x80
			while f < 0.5 or f >= 1.0:
				if f < 0.5:
					f = f * 2.0
					exponent -= 1
				else:
					f = f / 2.0
					exponent += 1
			mantissa = int(f * 0x100000000)
			#print(fOrg,pow(2.0,exponent-128)*mantissa/0x100000000)

		self.tgt.write("\t.byte 	1     ; *** Load Float {0} ***\n".format(fOrg))
		self.tgt.write("\t.dword 	${0:x}\n".format(mantissa))
		self.tgt.write("\t.byte 	${0:02x},${1:x}\n".format(exponent,szByte))
	#
	def command(self,c):
		self.tgt.write("\t.byte 	${0:02x}   ; *** Command {1} ***\n".format(ord(c),c))
	#
	def end(self):
		self.tgt.write("\t.byte 	0\n")

if __name__ == "__main__":
	fc = FScriptCompiler()
	fc.float(99.94)
	fc.integer(42)
	fc.end()
