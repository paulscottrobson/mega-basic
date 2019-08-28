# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		showv.py
#		Purpose :	Show Expression stack
#		Date :		25th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

def formatArray(mem,pa,type,depth):
	p = mem[pa]+mem[pa+1]*256
	size = mem[p]+mem[p+1]*256
	s = "\n{0}[${3:04x}] ${1:04x} (0-{2}) ".format("\t"*depth,p,(size & 0x7FFF)-1,pa)
	if (size & 0x8000) != 0:
		for i in range(0,size & 0x7FFF):
			na = mem[p+i*2+2] + mem[p+i*2+3] * 256
			s = s + formatArray(mem,p+i*2+2,type,depth+1)
	else:
		p = p + 2
		for i in range(0,size):
			#s = s + "{0:04x}".format(p)+" "
			s = s + formatData(mem,p,type)+" "
			p = p + [2,5,4][type]
	return s

def formatData(mem,addr,type):
	if type == 0:
		sa = mem[addr]+mem[addr+1] * 256
		s = ""
		if sa != 0:
			for i in range(0,mem[sa]):
				s = s + chr(mem[i+sa+1])
		return '"'+s+'"'# +' @ {0:04x}'.format(sa)
	#
	mantissa = mem[addr]+(mem[addr+1] << 8)+(mem[addr+2] << 16)+(mem[addr+3] << 24)
	#
	if type == 2:
		if (mantissa & 0x80000000):
			mantissa -= 0x100000000
		return str(mantissa)
	#
	exponent = mem[addr+4]
	if exponent == 0:
		return "0.0"
	sign = "-" if (mantissa & 0x80000000) != 0 else ""
	mantissa = mantissa | 0x80000000
	fpv = pow(2.0,(exponent-128)) * mantissa / 0x100000000
	return sign + str(fpv)

mem = [x for x in open("memory.dump","rb").read(0x10000)]
for i in range(0,6):	
	hashTable = 0x427+i*8*2
	print("--- {0}{1} ---".format(["string","real","int"][i >> 1],"" if i%2 == 0 else "()"))
	for he in range(0,8):
		ha = hashTable + he * 2
		hp = mem[ha] + mem[ha+1] * 256
		if hp != 0:
			print("\tHash index {0:2} @ ${1:04x}".format(he,ha))
			while hp != 0:
				name = ""
				p = hp + 3
				while p != 0:
					c = mem[p]
					name = name + chr(((c & 0x7F)^0x20)+0x20)
					p = p+1 if c < 0x80 else 0
				if i % 2 == 0:
					data = formatData(mem,hp+3+len(name),i >> 1)
				else:
					data = formatArray(mem,hp+3+len(name),i >> 1,1)
				name = name.lower()+"$#%"[i >> 1]
				print("\t\t${0:04x} {1:6} (#${2:02x}) = {3}".format(hp,name,mem[hp+2],data))
				hp = mem[hp] + mem[hp+1] * 256
