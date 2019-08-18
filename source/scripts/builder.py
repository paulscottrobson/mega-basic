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

class BuildException(Exception):
	pass

class BuildDefinition(object):
	def __init__(self):
		self.processor = "65816"												# save CPU type, Machine type.
		self.hardware = "em65816"
		self.machine = "em65816"
		self.modules = []														# List of modules
		self.usedFiles = {}														# Files included
		self.defines = { "CPU":self.processor };
		self.defaults()															# Standard mandatory modules
		self.interface()														# Character Interface Modules.
		self.create()															# Files in this file.
		self.generate()

	def defaults(self):
		self.addModule("common.*")												# common stuff
		self.addModule("machine.@h")											# cpu machine code

	def interface(self):
		self.addModule("interface.common.*")									# common interface
		self.addModule("interface.drivers.interface_@m")						# specific interface for machine

	def addModule(self,moduleName):
		moduleName = BuildDefinition.MODULES+os.sep+moduleName 					# Module directory.
		moduleName = moduleName.replace(".",os.sep).strip()						# process dots
		moduleName = moduleName.replace("/",os.sep)								# Fucking Microsoft can't even copy
		moduleName = moduleName.replace("@c",self.processor)					# replacements
		moduleName = moduleName.replace("@m",self.machine)
		moduleName = moduleName.replace("@h",self.hardware)
		if moduleName.endswith("*"):											# Use all in this module ?
			self.loadModuleSet(moduleName[:-2])
			return
		self.addFile(moduleName + ".asm",False)									# actual file name.

	def addFile(self,srcName,toFront):
		print("\tIncluding "+srcName)
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

	def generate(self):
		tgtFile = BuildDefinition.SOURCE+os.sep+"_include.asm"
		print("Writing to "+tgtFile)
		h = open(tgtFile,"w")
		h.write(";\n;\t\t AUTOMATICALLY GENERATED.\n;\n")
		h.write("".join(['{0} = "{1}"\n'.format(k,self.defines[k]) for k in self.defines.keys()]))
		h.write("".join(['\t.include "{0}"\n'.format(f) for f in self.modules]))
		h.close()

BuildDefinition.PROJECTROOT = "/home/paulr/Projects/6502-Basic"						# Root of project
BuildDefinition.SOURCE = BuildDefinition.PROJECTROOT+"/source"					# Source Root
BuildDefinition.MODULES = "modules"												# Modules here from source directory.

class Emulated65816Full(BuildDefinition):
	def create(self):
		self.addModule("utility.tim")											# TIM code.
		self.addModule("float.*")												# FP Stuff
		self.addModule("integer.*")												# INT32 Stuff.
		self.addModule("integer.convert.*")										# INT32 conversion stuff
		self.addModule("testing.fptest")
	

if __name__ == "__main__":
	sys = Emulated65816Full()
