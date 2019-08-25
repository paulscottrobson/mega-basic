#
#		Array checking program . 
#
sizes = [ 2,3,4 ]

def calculateIndex(indexes,sizes):
	current = 0
	for p in range(0,len(indexes)):
		if p > 0:
			current = current * sizes[p]
		current = current + indexes[p]
	return current

for s1 in range(0,sizes[0]):
	for s2 in range(0,sizes[1]):
		for s3 in range(0,sizes[2]):
			indices = [s1,s2,s3]
			print(indices,calculateIndex(indices,sizes))


# Variable
#
#		-2 	Second character (etc.)
#		-1 	First character
#		+0 	[Length (0-4), Dimensions (5-7)]
#		+1 	(Data)
#
#		or
#		+1 	Max dimension (word)
#		+3  Array of elements (top dimension)
#
#		or
#		+1	Max dimension (word)
#		+2	Array of pointers to other tables.
#
#	Set up table of dimensions which is the default creation, then can use access/read automatically.
#	
#	Hash table of names, simple additive will do, 8 x 6 tables.
#



