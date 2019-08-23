# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		showxs.py
#		Purpose :	Show Expression stack
#		Date :		15th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

mem = [x for x in open("memory.dump","rb").read(0x10000)]
for v in range(0,4):
	a = v * 6 + 0x308
	mantissa = mem[a] + (mem[a+1] << 8)+ (mem[a+2] << 16)+ (mem[a+3] << 24)
	exponent = mem[a+4]
	szByte = mem[a+5]
	print("Register {0} at ${1:04x} Mantissa:{2:08x} Exponent:{3:02x} Type:{4:02x}".
			format(v+1,a,mantissa,exponent,szByte))
	if (szByte & 0x01):
	 	mantissa = mantissa if (mantissa & 0x80000000) == 0 else mantissa - 0x100000000
	 	print("\tInteger {0}".format(mantissa))	
	if (szByte & 0x02):
	 	addr = mantissa & 0xFFFF
	 	s = ""
	 	for i in range(0,mem[addr]):
	 		s = s + chr(mem[addr+i+1])
	 	print("Address ${0:04x} Length:{1} String:{2}".format(addr,mem[addr],s))
	if (szByte & 0x0F) == 0:
	 	fpv = 0.0
	 	if (szByte & 0x40) == 0:
	 		fpv = pow(2.0,(exponent-128)) * mantissa / 0x100000000
	 		if szByte & 0x80:
	 			fpv = -fpv
	 	print("\tFloat {0}".format(fpv))
	print()

a = 0x400
s = ""
while a < 0x420 and mem[a] != 0x00:
	s = s + chr(mem[a])
	a += 1
print("Buffer contains '{0}'".format(s))