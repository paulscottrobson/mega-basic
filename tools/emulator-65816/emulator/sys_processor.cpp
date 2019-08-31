// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		processor.cpp
//		Purpose:	Processor Emulation.
//		Created:	17th April 2019
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#include "sys_processor.h"
#include "gfx.h"

// *******************************************************************************************************************************
//															Timing
// *******************************************************************************************************************************
	
#define CYCLES_PER_SECOND	(8000000*0.43)											// 8Mhz ish.
#define FRAME_RATE			(60)													// Frame rate
#define CYCLES_PER_FRAME	(CYCLES_PER_SECOND/FRAME_RATE)							// T-States per second.

static LONG32 Cycles = 0;
static LONG32 instructionCount = 0; 

#define HWIReset() {}
#define HWIEndFrame() {}

// *******************************************************************************************************************************
//														Main Memory
// *******************************************************************************************************************************

static BYTE8 ramMemory[RAMSIZE];													// RAM memory
#define RAMMASK (RAMSIZE-1)

// *******************************************************************************************************************************
//													Memory read and write macros.
// *******************************************************************************************************************************

#define LOAD_LONG(addr) (ramMemory[(addr) & RAMMASK])
#define STORE_LONG(addr,data) {ramMemory[(addr) & RAMMASK] = data; }
#define FETCH_PARAM(src) (ramMemory[((src) | CPU65816GetBank()) & RAMMASK]) 

// *******************************************************************************************************************************
//														Reset the CPU
// *******************************************************************************************************************************

void CPUReset(void) {
	CPU65816Reset();
	HWIReset();
	Cycles = 0;	
	for (int i = 0;i < 64*32;i++)
		ramMemory[(i+0xF0000) & RAMMASK] = rand() & 0xFF;
}

// *******************************************************************************************************************************
//													 Execute a single phase.
// *******************************************************************************************************************************

#include "stdio.h"

BYTE8 CPUExecuteInstruction(void) {
	Cycles++;
	instructionCount++;
	CPU65816ExecuteOneInstruction();
	if (Cycles < CYCLES_PER_FRAME) return 0;										// Frame in progress, return 0.
	Cycles -= CYCLES_PER_FRAME;														// Adjust cycle counter
	HWIEndFrame();																	// Hardware stuff.
	ramMemory[0xF8000 & RAMMASK] = (GFXIsKeyPressed(GFXKEY_CONTROL) && GFXIsKeyPressed('C')) ? 1 : 0;				
	return FRAME_RATE;																// Return the frame rate for sync speed.
}

#ifdef INCLUDE_DEBUGGING_SUPPORT

// *******************************************************************************************************************************
//												Handle keypress
// *******************************************************************************************************************************

int CPUKeyHandler(int key,int inRunMode) {
	if (inRunMode) {
		ramMemory[0xF8010 & RAMMASK] = GFXToASCII(key,-1);
	}	
	return key;
}

// *******************************************************************************************************************************
//												Read a byte
// *******************************************************************************************************************************

BYTE8 CPURead(LONG32 address) {
	return ramMemory[address & RAMMASK];
}

// *******************************************************************************************************************************
//										 Get the step over breakpoint value
// *******************************************************************************************************************************

LONG32 CPUGetStepOverBreakpoint(void) {
	BYTE8 opcode = CPURead(PCTR);												// Read opcode.
	if (opcode == 0x20 || opcode == 0xFC) return PCTR+3;
	if (opcode == 0x22) return PCTR+4;
	return 0;
}

// *******************************************************************************************************************************
//										Run continuously till breakpoints / Halt.
// *******************************************************************************************************************************

BYTE8 CPUExecute(LONG32 break1,LONG32 break2) {
	BYTE8 rate = 0;
	while(1) {
		rate = CPUExecuteInstruction();												// Execute one instruction phase.
		if (rate != 0) {															// If end of frame, return rate.
			return rate;													
		}
		if (CPURead(PCTR) == 0xEA) return 0;										// stop on NOP.
		if (CPURead(PCTR) == 0x02) { 												// stop on COP.
			GFXCloseOnDebug();
			return 0;	
		}
		if (PCTR == break1 || PCTR == break2) return 0;
	} 																				// Until hit a breakpoint or HLT.
}

#include "65816.c"

// *******************************************************************************************************************************
//												Load a binary file into RAM
// *******************************************************************************************************************************

#include <stdio.h>

void CPULoadBinary(char *fileName) {
	FILE *f = fopen(fileName,"rb");
	int n = 0;
	while (!feof(f)) {
		ramMemory[n++] = fgetc(f);
	}
	printf("%d %s\n",n,fileName);
	CPUReset();
	fclose(f);
}

// *******************************************************************************************************************************
//													Called on Program end
// *******************************************************************************************************************************

void CPUEndRun(void) {
	printf("Executed %ld instructions.\n",instructionCount);
	double time = instructionCount / 430000.0;
	printf("At 1Mhz this is about %.2lf seconds.\n",time);
	printf("At 8Mhz this is about %.2lf seconds.\n",time/8.0);
	FILE *f = fopen("memory.dump","wb");
	for (LONG32 l = 0x0000;l < 0x10000;l += 1024) {
		fwrite(ramMemory+l,1,1024,f);
	}
	fclose(f);
}

// *******************************************************************************************************************************
//											Retrieve a snapshot of the processor
// *******************************************************************************************************************************

CPUSTATUS status;

CPUSTATUS *CPUGetStatus(void) {
	REGISTERSET r;
	CPU65816GetStatus(&r);
	status.pc=r.pc;
	status.a=r.a | (r.b << 8);
	status.x=r.x;
	status.y=r.y;
	status.emul=r.emul;
	status.dpr=r.dpr;
	status.pbr=r.pbr;
	status.dbr=r.dbr;
	status.sp=r.sp;
	status.p= r.p & (0xFF ^ (P_SIGN|P_ZERO));
	status.count = instructionCount;
	if (r.z == 0) status.p |= P_ZERO;
	if (r.n != 0) status.p |= P_SIGN;
	return &status;
}
#endif
