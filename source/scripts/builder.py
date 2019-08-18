# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		builder.py
#		Purpose :	Builds the include file to pick modules, or not.
#		Date :		15th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys

# *******************************************************************************************
#		
#										Exception class
#
# *******************************************************************************************

class BuildException(Exception):
	pass

# *******************************************************************************************
#
#								Class that defines a specific build
#
# *******************************************************************************************

class BuildDefinition(object):
	def __init__(self,setup):
		self.processor = setup.getProcessor()									# what CPU
		self.hardware = setup.getHardware()										# the machine hardware, memory layout etc.
		self.interface = setup.getInterface()									# Interface stuff.

		self.modules = []														# List of modules
		self.usedFiles = {}														# Files included
		self.defines = { "CPU":self.processor,"HARDWARE":self.hardware };
		defaultint = ".word DefaultInterrupt"
		self.macros = { "boot": None, "irqhandler":defaultint,"nmihandler":defaultint }

	def analyse(self):
		self.defaultsCreate()													# Standard mandatory modules
		self.interfaceCreate()													# Character Interface Modules.
		self.create()															# Files in this file.

	def setMacro(self,macro,code):
		self.macros[macro.lower()] = code

	def boot(self,bootLabel):
		self.setMacro("boot","jmp "+bootLabel)

	def addModule(self,moduleName):
		moduleName = BuildDefinition.MODULES+os.sep+moduleName 					# Module directory.
		moduleName = moduleName.replace(".",os.sep).strip()						# process dots
		moduleName = moduleName.replace("/",os.sep)								# Fucking Microsoft can't even copy
		moduleName = moduleName.replace("@c",self.processor)					# replacements
		moduleName = moduleName.replace("@i",self.interface)
		moduleName = moduleName.replace("@h",self.hardware)
		if moduleName.endswith("*"):											# Use all in this module ?
			self.loadModuleSet(moduleName[:-2])
			return
		self.addFile(moduleName + ".asm",False)									# actual file name.

	def addFile(self,srcName,toFront):
		#print("\tIncluding "+srcName)
		if not os.path.isfile(srcName):											# check it exists.
			raise BuildException("Cannot find '{0}'".format(srcName))
		if srcName in self.usedFiles:			
			raise BuildException("Already included '{0}'".format(srcName))
		self.usedFiles[srcName] = True
		if toFront:
			self.modules.insert(0,srcName)
		else:
			self.modules.append(srcName)

	def loadModuleSet(self,moduleDirectory):
		if not os.path.isdir(moduleDirectory):									# check it exists
			raise BuildException("Cannot find '{0}'".format(moduleDirectory))
		for f in [x for x in os.listdir(moduleDirectory) if x.endswith(".inc")]:# output assembly files in there.
			self.addFile(moduleDirectory+os.sep+f,True)
		for f in [x for x in os.listdir(moduleDirectory) if x.endswith(".asm")]:# output assembly files in there.
			self.addFile(moduleDirectory+os.sep+f,False)

	def targetFile(self):
		return BuildDefinition.SOURCE+os.sep+"_include.asm"

	def generate(self):
		#print("Writing to "+tgtFile)
		h = open(self.targetFile(),"w")
		h.write(";\n;\t\t AUTOMATICALLY GENERATED.\n;\n")
		for k in self.macros.keys():
			if self.macros[k] is not None:
				h.write("{0}: .macro\n\t{1}\n\t.endm\n".format(k,self.macros[k]))

		h.write("".join(['{0} = "{1}"\n'.format(k,self.defines[k]) for k in self.defines.keys()]))
		h.write("".join(['\t.include "{0}"\n'.format(f) for f in self.modules]))
		h.close()

	def defaultsCreate(self):
		self.addModule("common.*")												# common stuff
		self.addModule("hardware.@h")											# cpu memory layout etc.

	def interfaceCreate(self):
		self.addModule("interface.common.*")									# common interface
		self.addModule("interface.drivers.interface_@i")						# specific interface for machine


BuildDefinition.PROJECTROOT = "/home/paulr/Projects/6502-Basic"					# Root of project
BuildDefinition.SOURCE = BuildDefinition.PROJECTROOT+"/source"					# Source Root
BuildDefinition.MODULES = "modules"												# Modules here from source directory.

# *******************************************************************************************
#
#									Some Build Definitions
#
# *******************************************************************************************

class CheckTIM(BuildDefinition):
	def create(self):
		self.addModule("utility.tim")											# TIM code.
		self.setMacro("irqhandler",".word TIM_BreakVector")
		self.boot("TIM_Start")

class FloatingPointTest(BuildDefinition):
	def create(self):
		self.addModule("float.*")												# FP Stuff
		self.addModule("utility.tim")											# nicked hex printing routines :)
		self.addModule("testing.fptest")
		self.boot("FPTTest")

# *******************************************************************************************
#
#								Physical Hardware Definition
#
# *******************************************************************************************

class Hardware(object):
		pass

class Emulated65816Machine(Hardware):
	def getProcessor(self):
		return "65816"
	def getHardware(self):
		return "em65816"
	def getInterface(self):
		return "em65816"


if __name__ == "__main__":
	try:
		build = FloatingPointTest(Emulated65816Machine())
		#build = CheckTIM(Emulated65816Machine())	
		build.analyse()
		build.generate()
	except BuildException as ex:
		print("*** "+str(ex)+" ***")
		if os.path.isfile(build.targetFile()):
			os.remove(build.targetFile())
