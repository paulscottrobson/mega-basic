// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		sys_debug_system.h
//		Purpose:	Debugger Code (System Dependent) Header
//		Created:	17th April 2019
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#ifndef _DEBUG_SYS_H
#define _DEBUG_SYS_H
#include "sys_processor.h"

#define WIN_TITLE 		"65816 Emulator"											// Initial Window stuff
#define WIN_WIDTH		(60*6*3)
#define WIN_HEIGHT		(28*8*3+32)
#define WIN_BACKCOLOUR	0x003

// *******************************************************************************************************************************
//							These functions need to be implemented by the dependent debugger.
// *******************************************************************************************************************************

#define DEBUG_ARGUMENTS(ac,av) if (ac >= 2) CPULoadBinary(av[1]);					// Handle CLI arguments
#define DEBUG_CPURENDER(x) 	DBGXRender(x,0)											// Render the debugging display
#define DEBUG_VDURENDER(x)	DBGXRender(x,1)											// Render the game display etc.

#define DEBUG_RESET() 		CPUReset()												// Reset the CPU / Hardware.
#define DEBUG_HOMEPC()		(CPU65816GetPC()) 										// Get PC Home Address (e.g. current PCTR value)

#define DEBUG_SINGLESTEP()	CPUExecuteInstruction()									// Execute a single instruction, return 0 or Frame rate on frame end.
#define DEBUG_RUN(b1,b2) 	CPUExecute(b1,b2) 										// Run a frame or to breakpoint, returns -1 if breakpoint
#define DEBUG_GETOVERBREAK() CPUGetStepOverBreakpoint()								// Where would we break to step over here. (0 == single step)

#define DEBUG_RAMSTART 		(0x0000)												// Initial RAM address for debugger.
#define DEBUG_SHIFT(d,v)	((((d) << 4) | v) & 0xFFFFFF)							// Shifting into displayed address.

#define DEBUG_KEYMAP(k,r) 	CPUKeyHandler(k,r)										// Runtime can remap/process keys etc.

void DBGXRender(int *address,int showCPU);											// Render the debugger screen.

#endif