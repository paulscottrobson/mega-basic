# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		tokenise.py
#		Purpose :	Worker class : converts string to a byte sequence.
#		Date :		19th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,re
from tokens import *

# *******************************************************************************************
#
#									Tokeniser Class
#
# *******************************************************************************************

class Tokeniser(object):
	def __init__(self):
		self.tokens = Tokens().get()										# get tokens.
		self.longest = 0 													# length of longest:
		for k in self.tokens.keys():
			if not k.startswith("!!"):	
				self.longest = max(self.longest,len(k))
	#
	#		Tokenise a single string.
	#
	def tokenise(self,s):
		s = s.replace("\t"," ").strip() 									# strip all spaces.
		self.byteData = []													# clear the byte array.
		while s != "":														# keep tokenising.
			s = self.tokeniseOne(s)	
		self.byteData.append(0)												# the final token.
		return self.byteData
	#
	#		Tokenise a single element.
	#
	def tokeniseOne(self,s):
		if s[0] == " ":														# Remove spaces.
			return s[1:]
		#
		if s[:3].lower() == "rem":											# Remark ?
			s = s[3:].strip() 												# remove REM and any spaces.
			n = len(s) if s.find(":") < 0 else s.find(":")					# find split point.
			self.addTokenSequence(0xFF,s[:n])								# add as token sequence.
			return s[n:]													# return the rest.
		#
		if s[0] == '"':														# Quoted string.
			s = s[1:]														# Remove quote
			n = len(s) if s.find('"') < 0 else s.find('"')					# find split point. fixes missing "
			self.addTokenSequence(0xFE,s[:n])								# add as token sequence.
			return s[n+1:]
		#
		m = re.match("^\\.(\\d+)(.*)$",s)									# .<decimals><the rest>
		if m is not None:
			m1 = re.match("^([Ee]\\-?\\d+)(.*)$",m.group(2))				# exponent check.
			if m1 is not None:
				self.addTokenSequence(0xFD,m.group(1)+m1.group(1))
				return m1.group(2)
			#
			self.addTokenSequence(0xFD,m.group(1))							# add as token sequence.
			return m.group(2)
		#
		m = re.match("^(\\d+)(.*)$",s)										# Numeric integer constant
		if m is not None:
			self.addIntegerSequence(int(m.group(1)))
			return m.group(2)
		#
		for l in range(self.longest,0,-1):									# check the tokens
			token = s[:l].lower()											# what to test
			if token in self.tokens: 										# is it there ?
				n = self.tokens[token]["token"]								# get the ID.
				if n >= 0x100:												# shifted.
					self.byteData.append(n >> 8)
				self.byteData.append(n & 0xFF)								# body
				return s[l:]
		#																	# Single character.
		c = s[0].upper() 													# get as U/C
		assert c != "@" and ord(c) < 0x5F,"Cannot tokenise {0}".format(s)	# must be $20-$5F and not @
		self.byteData.append(ord(c) & 0x3F)									# add that.
		return s[1:]
	#
	#		Add a token sequence
	#		
	def addTokenSequence(self,marker,s):
		self.byteData.append(marker)										# marker
		self.byteData.append(len(s)+2)										# overall length.
		for c in s:
			self.byteData.append(ord(c))									# add sequence as ASCII
	#
	#		Add an integer sequence.
	#
	def addIntegerSequence(self,n):
		if n > 0x3F:														# requires a shift.
			self.addIntegerSequence(n >> 6)									# do the upper bit
		self.byteData.append((n & 0x3F) + 0x40)								# add the integer token.		
	#
	#		Tokenise tester.
	#
	def test(self,s):
		print("Tokenising [{0}]".format(s))
		sequence = self.tokenise(s)
		print("\t"+" ".join(["{0:02x}".format(x) for x in sequence]))

if __name__ == "__main__":
	tok = Tokeniser()
	tok.test("rem hel:lo")
	tok.test('""')
	tok.test('"abc" abc')
	tok.test('"def')
	tok.test('41.102 42 0 0.')
	tok.test('12.304e-4 xx')
	tok.test('4.2-3.1')
	tok.test("for i = 0 to 9:next i,j")
	tok.test("name$(4)")
	tok.test("a>b>=c")
#
#		Token format:
#
#		$FF	nn 		REM sequence. nn is byte offset to next token, so n-2 characters
#		$FE nn		String sequence. (same). Quotes are not included.
#		$FD nn 		Decimal sequence. (same). Does not include DP at start. 
#		$FA-$FC cc 	Reserved
#		$F8-$F9 tt	Token shift
#		$80-$F7 	Single byte tokens.
#		$40-$7F 	6 bit unsigned constant, shifted in (after first) - subsequent
#					constants ; shift the whole thing left 6 and add constant to base.
#		$01-$3F 	6 bit ASCII characters (mostly for identifiers and spaces)
#		$00			End of line.
#
