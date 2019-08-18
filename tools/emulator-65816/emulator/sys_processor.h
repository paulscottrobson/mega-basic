// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		processor.h
//		Purpose:	Processor Emulation (header)
//		Created:	17th April 2019
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#ifndef _SYS_PROCESSOR_H
#define _SYS_PROCESSOR_H

typedef unsigned int   LONG32; 														// 32 bit types
typedef unsigned short WORD16;														// 8 and 16 bit types.
typedef unsigned char  BYTE8;

#define RAMSIZE	(0x100000)															// 0.5Mb RAM

#define DEFAULT_BUS_VALUE (0xFF)													// What's on the bus if it's not memory.

void CPUReset(void);																// CPU methods
void CPUEndRun(void);

BYTE8 CPUExecuteInstruction(void);													// Execute one instruction (multi phases)

void HWIReset(void);																// Reset hardware.
void HWIEndFrame(void);																// End of frame function

typedef struct _CPUStatus {
	WORD16 pc;     
	WORD16 a;       
	WORD16 x;       
	WORD16 y;       
	WORD16 emul; 
	WORD16 dpr;   
	WORD16 pbr;   
	WORD16 dbr;   
	WORD16 sp;     
	WORD16 p;       
} CPUSTATUS;

CPUSTATUS *CPUGetStatus(void);														// Access CPU State
void CPULoadBinary(char *fileName);													// Load Binary in.
BYTE8 CPURead(LONG32 address);														// Access RAM
BYTE8 CPUExecute(LONG32 break1,LONG32 break2);										// Run to break point(s)
LONG32 CPUGetStepOverBreakpoint(void);												// Get step over breakpoint
int CPUKeyHandler(int key,int inRunMode);

#include "65816.h"

#define PCTR	CPU65816GetPC()
#endif
