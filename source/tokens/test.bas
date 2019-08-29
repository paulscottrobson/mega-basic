		rem this is a comment.
		rem wait 6502,1
		gosub 1000:gosub 1000:stop		
1000	print "Hello !"
		X = 2
		while X > 0
			Y = 0
			repeat
				IF X = 2
					print "Its 2 !     ";
				else
					print "Its not 2 ! ";
				endif
				PRINT X;Y:Y = Y + 1
			until Y = 3:X=X-1
		wend
		print "End."
		return	
