# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		builderclass.py
#		Purpose :	Base Builder Class
#		Date :		18th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,platform

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
	#
	#		Initialise build definition for a specific setup - CPU, layout, interface and
	#		execution platform.
	#
	def platform(self,setup):
		self.processor = setup.getProcessor()									# what CPU
		self.hardware = setup.getHardware()										# the machine hardware
		self.platform = setup.getPlatform()										# what its run on.
		self.runScript = setup.getBuildScript()									# what to run it with.

		self.modules = []														# List of modules
		self.usedFiles = {}														# Files included
		self.defines = { "cpu":self.processor,"hardware":self.hardware };

		defaultint = "\t.word DefaultInterrupt"

		self.macros = { "boot": None, 											# What to run.
						"irqhandler":defaultint,								# NMI/IRQ addresses
						"nmihandler":defaultint,
						"fatal":"\tjsr ERR_Handler\n\t.text \\1,0\n"			# Error - ASCIIZ message follows
		}						
		self.defines["exitonend"] = 0 											# if set to 1, exits on END command 						
		self.defines["autorun"] = 0
		self.defines["loadtest"] = 0		
	#
	#		Analyse the source requirements, add the various classes, macros.
	#
	def analyse(self):
		self.defaultsCreate()													# Standard mandatory modules
		self.interfaceCreate()													# Character Interface Modules.
		self.create()															# Files in this file.
	#
	#		Assign a define value
	#		
	def define(self,label,value):
		self.defines[label.lower()] = value
	#
	#		Assign a value to a new or current macro
	#
	def setMacro(self,macro,code):
		self.macros[macro.lower()] = code
	#
	#		Set the boot address, the first thing run after initialisation/stack reset
	#
	def boot(self,bootLabel):
		self.setMacro("boot","jmp "+bootLabel)
	#
	#		Add a single module e.g. demo.module.xx or a group demo.module.* does not recur
	#		into subdirectories.
	#
	def addModule(self,moduleName):
		moduleName = BuildDefinition.MODULES+os.sep+moduleName 					# Module directory.
		moduleName = moduleName.replace(".",os.sep).strip()						# process dots
		moduleName = moduleName.replace("/",os.sep)								# Fucking Microsoft can't even copy
		moduleName = moduleName.replace("@c",self.processor)					# replacements
		moduleName = moduleName.replace("@h",self.hardware)
		if moduleName.endswith("*"):											# Use all in this module ?
			self.loadModuleSet(moduleName[:-2])
			return
		self.addFile(moduleName + ".asm",False)									# actual file name.
	#
	#		Add a single file, can be to the front (for includes) or back (for assembly)
	#
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
	#
	#		Get all modules (.asm .inc) in a directory (does not recurse into subdirectories)
	#
	def loadModuleSet(self,moduleDirectory):
		if not os.path.isdir(moduleDirectory):									# check it exists
			raise BuildException("Cannot find '{0}'".format(moduleDirectory))
		for f in [x for x in os.listdir(moduleDirectory) if x.endswith(".inc")]:# output assembly files in there.
			self.addFile(moduleDirectory+os.sep+f,True)
		for f in [x for x in os.listdir(moduleDirectory) if x.endswith(".asm")]:# output assembly files in there.
			self.addFile(moduleDirectory+os.sep+f,False)
	#
	#		Name of include file to write
	#
	def targetFile(self):														# file created for source
		return BuildDefinition.SOURCE+os.sep+"_include.asm"
	#
	#		Name of shell/batch script file to write.
	#
	def scriptFile(self):														# shell created to run script
		filetype = ".bat" if platform.system() == "Windows" else ".sh"			# figure out target
		return BuildDefinition.SOURCE+os.sep+"_exec{0}".format(filetype) 		# return name
	#
	#		Generate include and scripts
	#
	def generate(self):
		#print("Writing to "+tgtFile)
		h = open(self.targetFile(),"w")											# create include file
		h.write(";\n;\t\t AUTOMATICALLY GENERATED.\n;\n")
		for k in self.macros.keys():											# output macros
			if self.macros[k] is not None:
				h.write("{0}: .macro\n\t{1}\n\t.endm\n".format(k,self.macros[k]))
																				# output equates
		h.write("".join(['{0} = {1}\n'.format(k,self.toFormat(self.defines[k])) for k in self.defines.keys()]))
																				# output included files.
		h.write("".join(['\t.include "{0}"\n'.format(f) for f in self.modules]))
		h.close()
		#
		h = open(self.scriptFile(),"w")											# create script file
		sdir = BuildDefinition.SOURCE+os.sep+"scripts"+os.sep+"runners"			# runners directory
		sdir = sdir + os.sep +(platform.system().lower())+os.sep 				# platform specific.
		for f in ["common.start",self.runScript]:								# concatenate files.
			h1 = open(sdir+f)
			h.write(h1.read(-1))
			h1.close()
		h.close()
		#
		h = open(BuildDefinition.SOURCE+os.sep+"_files.lst","w")				# List of files.
		h.write("::".join(self.modules))
		h.close()
	#
	def toFormat(self,v):
		return '"'+v+'"' if isinstance(v,str) else v
	#
	#		Default startup stuff for eeerything
	#
	def defaultsCreate(self):
		self.addModule("basic.data.*")
		self.addModule("hardware.@h")											# cpu memory layout etc.
	#
	#		Interface creation.
	#
	def interfaceCreate(self):
		self.addModule("interface.common.*")									# common interface
		self.addModule("interface.drivers.interface_@h")						# specific interface for machine

#
#		Physical locations of various things.
#
BuildDefinition.PROJECTROOT = "/home/paulr/Projects/6502-Basic"					# Root of project
BuildDefinition.SOURCE = BuildDefinition.PROJECTROOT+"/source"					# Source Root
BuildDefinition.MODULES = "modules"												# Modules here from source directory.
