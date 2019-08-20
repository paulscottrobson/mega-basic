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

Hardware.Classes = { 	"e816":	Emulated65816Machine,
						"fm65":	FPGAMachine,
						"xemu":	XEmuMachine }

# *******************************************************************************************
#
#									Some Build Definitions
#
# *******************************************************************************************

class TIMOnlyTest(BuildDefinition):												# Something just running TIM
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
		self.define("hasFloat",1)
		self.define("hasInteger",1)
		self.addModule("basic.*")	
		self.addModule("basic.expressions.*")	
		self.addModule("basic.pointer.@h.*")
		self.addModule("float.*")												# FP Stuff
		self.addModule("float.convert.*")
		self.addModule("integer.*")
		self.addModule("integer.convert.*")
		self.addModule("utility.tim")											# nicked hex printing routines :)
		self.setMacro("irqhandler",".word TIM_BreakVector")
		#
		self.addModule("basic.testcode.*")
		self.boot("BASIC_Start")

BuildDefinition.Classes = {														# Class list
		"tim":	TIMOnlyTest,
		"fpch":	FloatingPointTest,
		"full":	FullBasic
}

if __name__ == "__main__":
	try:
		hardwareName = "e816"													# defaults
		buildName = "full"	

		for changes in [x.lower() for x in sys.argv[1:]]:
			if changes in Hardware.Classes:
				hardwareName = changes
			elif changes in BuildDefinition.Classes:
				buildName = changes
			else:
				print("Build    : {0}".format(" ".join(BuildDefinition.Classes.keys())))
				print("Hardware : {0}".format(" ".join(Hardware.Classes.keys())))
				build = FullBasic()

				raise BuildException("Unknown '{0}'".format(changes))

		hardware = Hardware.Classes[hardwareName]()
		build = BuildDefinition.Classes[buildName]()

		build.platform(hardware)
		build.analyse()
		build.generate()

	except BuildException as ex:
		print("*** "+str(ex)+" ***")
		if os.path.isfile(build.targetFile()):
			os.remove(build.targetFile())
		if os.path.isfile(build.scriptFile()):
			os.remove(build.scriptFile())
