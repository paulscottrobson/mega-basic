# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		builder.py
#		Purpose :	Builds the include file to pick modules, or not.
#		Date :		18th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys
from builderclass import *

# *******************************************************************************************
#
#								Physical Hardware Definitions
#
# *******************************************************************************************

class Hardware(object):
	def getBuildScript(self):
		return self.getPlatform()+".start"
	def getPlatform(self):
		return self.getHardware()

class Emulated65816Machine(Hardware):											# emulated 6502/65816 machine.
	def getProcessor(self):
		return "65816"
	def getHardware(self):
		return "em65816"

class FPGAMachine(Hardware):													# FPGA Mega 65
	def getProcessor(self):
		return "4510"
	def getHardware(self):
		return "mega65"

class XEmuMachine(FPGAMachine):													# Xemu emulator (Mega 65)
	def getPlatform(self):
		return "xemu"

# *******************************************************************************************
#
#									Some Build Definitions
#
# *******************************************************************************************

class CheckTIM(BuildDefinition):												# Something just running TIM
	def create(self):
		self.addModule("utility.tim")											# TIM code.
		self.setMacro("irqhandler",".word TIM_BreakVector")
		self.boot("TIM_Start")

class FloatingPointTest(BuildDefinition):										# Run FP Unit Test.
	def create(self):
		self.addModule("float.*")												# FP Stuff
		self.addModule("utility.tim")											# nicked hex printing routines :)
		self.addModule("testing.fptest")
		self.boot("FPTTest")

class FullBasic(BuildDefinition):
	def create(self):
		self.addModule("basic.*")
		self.addModule("float.*")												# FP Stuff
		self.addModule("float.convert.*")
		self.addModule("integer.*")
		self.addModule("integer.convert.*")
		self.addModule("utility.tim")											# nicked hex printing routines :)
		self.setMacro("irqhandler",".word TIM_BreakVector")
		self.boot("BASIC_Start")

if __name__ == "__main__":
	try:
		hw = Emulated65816Machine()
		classID = FloatingPointTest
		#hw = XEmuMachine()
		#hw = FPGAMachine()
		build = classID()
		#build = CheckTIM()	
		#build = FullBasic()

		build.platform(hw)
		build.analyse()
		build.generate()

	except BuildException as ex:
		print("*** "+str(ex)+" ***")
		if os.path.isfile(build.targetFile()):
			os.remove(build.targetFile())
		if os.path.isfile(build.scriptFile()):
			os.remove(build.scriptFile())
