# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		Tokens.py
#		Purpose :	Raw tokens class.
#		Date :		19th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,re

# *******************************************************************************************
#
#											Tokens Class
#
# *******************************************************************************************

class Tokens(object):
	def __init__(self):
		if Tokens.tokens is None:
			self.loadTokens()
	#
	#		Get information table.
	#	
	def get(self):
		return Tokens.tokens
	#
	#		Create tokens information table.
	#
	def loadTokens(self):
		Tokens.tokens = {}
		raw = self.getRaw().replace("\t"," ").lower().split("\n")			# raw data as lines.
		raw = [x if x.find("##") < 0 else x[:x.find("##")] for x in raw]	# remove comments
		raw = [x for x in (" ".join(raw)).split(" ") if x != ""]			# split into single items.
		currentID = None 													# Known sections
		sections = {	"[keyword+]":	Tokens.KEYPLUS, 
						"[keyword-]":	Tokens.KEYMINUS,
						"[keyword]":	Tokens.KEYWORD,
						"[unary]":		Tokens.UNARY,
						"[syntax]":		Tokens.SYNTAX
		}
		for i in range(0,8):												# Add precedence levels.
			sections["["+str(i)+"]"] = i
		tokenID = 0x80 														# Next available token

		for w in raw:
			if w in sections:												# new section ?
				currentID = sections[w]	
				if currentID == Tokens.KEYMINUS:							# Track sections start
					Tokens.tokens["!!firstkeyminus"] = tokenID
				if currentID == Tokens.KEYPLUS:
					Tokens.tokens["!!firstkeyplus"] = tokenID
				if currentID == Tokens.UNARY:
					Tokens.tokens["!!firstunary"] = tokenID				
			else:
				assert re.match("^\\[.*\\]$",w) is None,"Bad section "+w
				assert currentID is not None,"No section"

				if currentID == Tokens.UNARY:								# Track unary end.
					Tokens.tokens["!!lastunary"] = tokenID
				keyword = { "name":w,"type":currentID, "token":tokenID }
				#print("{0:8} {1:2} ${2:x}".format(w,currentID,tokenID))

				Tokens.tokens[w] = keyword

				tokenID += 1	
				if (tokenID & 0xFF) > 0xF8:									# Handle shifts
					if tokenID < 0x100:
						tokenID = 0xF880
					else:
						tokenID = (tokenID & 0xFFFF) + 0x180
		Tokens.tokens["!!lasttoken"] = tokenID								# remember last token						
	#
	#		Get in raw format (## are comments)
	#
	def getRaw(self):
		return """
	##
	##	====================================================================
	##		IMPORTANT ! This must be ordered : Binary, Key+, Key-, Unary.
	##	====================================================================
	##
	##		Binary (or Binary/Unary) Keywords
	##
		[0]		and		or 		xor
		[1]		=		<> 		< 		<=		> 		>=
		[2] 	+ 		-
		[3] 	* 		/
		[4]		^

	##
	##		Keywords that adjust structure depth.
	##
	[keyword+]
		if 		while 	repeat	for
	[keyword-]
		then 	endif 	wend 	until	next
	##
	##		Unary Functions
	##
	[unary]
		not		fn( 	abs(	asc( 	int( 	peek( 	rnd(	usr(
		left$( 	right$(	mid$( 	spc( 	str$( 	val(	len(	hex$(
		sin( 	cos( 	tan( 	atn(	exp(	log( 	sqr(	
		dec( 	deek(	leek(	mod(
	##
	##		Keywords that require a one byte token.
	##
	[keyword]

	##
	##		Important syntactic seperators (that require a one byte token)
	##
	[syntax]
		$( 	$ 	#(	# 	%(	% 	( 	)	, 	: 	; 	


	##
	##		General Keywords/Syntax (for rough CBM compatibility)
	##
	[keyword]
		def 	clr 	stop	data	read	dim	
		to 		step  	gosub 	return	goto	
		input	let		list	new		old		on
		restore	poke	print	run 	stop	wait
		doke 	loke

"""		

Tokens.tokens = None

Tokens.SYNTAX 	= 	8
Tokens.KEYPLUS 	= 	9
Tokens.KEYMINUS = 	10
Tokens.KEYWORD = 11
Tokens.UNARY = 12

if __name__ == "__main__":
	tok = Tokens()

