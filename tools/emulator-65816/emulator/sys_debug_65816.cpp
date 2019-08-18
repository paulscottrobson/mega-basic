// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		sys_debug_65816.cpp
//		Purpose:	Debugger Code (System Dependent)
//		Created:	17th April 2019
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "gfx.h"
#include "sys_processor.h"
#include "sys_debug_system.h"
#include "debugger.h"

#define DBGC_ADDRESS 	(0x0F0)														// Colour scheme.
#define DBGC_DATA 		(0x0FF)														// (Background is in main.c)
#define DBGC_HIGHLIGHT 	(0xFF0)

#include "dasm65816.h"
#include "c64font.h"

int renderCount = 0;

// *******************************************************************************************************************************
//												Reset the 8008
// *******************************************************************************************************************************

void DBGXReset(void) {
	CPUReset();
}

// *******************************************************************************************************************************
//											This renders the debug screen
// *******************************************************************************************************************************

void DBGXRender(int *address,int showDisplay) {
	int n,x;
	char buffer[32];
	GFXSetCharacterSize(44,28);

	CPUSTATUS *s = CPUGetStatus();													// Get the CPU Status

	const char *labels[] = { "PCTR","A","X","Y","SP","SIGN","OVERF","AMODE","XMODE","DEC","IEN",
			"ZERO","CARRY","CPU","PBANK","DBANK","DPAGE","BREAK",NULL };
	n = 0;
	while (labels[n] != NULL) {
		GFXString(GRID(23,n),labels[n],GRIDSIZE,DBGC_ADDRESS,-1);
		n++;
	}
	n = 0;x = 32;
	GFXNumber(GRID(x,n),s->pbr,16,2,GRIDSIZE,DBGC_DATA,-1);		
	GFXString(GRID(x+2,n),":",GRIDSIZE,DBGC_DATA,-1);
	GFXNumber(GRID(x+3,n++),s->pc,16,4,GRIDSIZE,DBGC_DATA,-1);		
	GFXNumber(GRID(x,n++),s->a,16,4,GRIDSIZE,DBGC_DATA,-1);		
	GFXNumber(GRID(x,n++),s->x,16,4,GRIDSIZE,DBGC_DATA,-1);		
	GFXNumber(GRID(x,n++),s->y,16,4,GRIDSIZE,DBGC_DATA,-1);		
	GFXNumber(GRID(x,n++),s->sp,16,4,GRIDSIZE,DBGC_DATA,-1);		
	GFXNumber(GRID(x,n++),((s->p) & P_SIGN) ? 1 : 0,16,1,GRIDSIZE,DBGC_DATA,-1);		
	GFXNumber(GRID(x,n++),((s->p) & P_OVERFLOW) ? 1 : 0,16,1,GRIDSIZE,DBGC_DATA,-1);		
	GFXString(GRID(x,n++),((s->p) & P_65816_M) ? "8" : "16",GRIDSIZE,DBGC_DATA,-1);		
	GFXString(GRID(x,n++),((s->p) & P_65816_X) ? "8" : "16",GRIDSIZE,DBGC_DATA,-1);		
	GFXNumber(GRID(x,n++),((s->p) & P_DECIMAL) ? 1 : 0,16,1,GRIDSIZE,DBGC_DATA,-1);		
	GFXNumber(GRID(x,n++),((s->p) & P_INTERRUPT) ? 1 : 0,16,1,GRIDSIZE,DBGC_DATA,-1);		
	GFXNumber(GRID(x,n++),((s->p) & P_ZERO) ? 1 : 0,16,1,GRIDSIZE,DBGC_DATA,-1);		
	GFXNumber(GRID(x,n++),((s->p) & P_CARRY) ? 1 : 0,16,1,GRIDSIZE,DBGC_DATA,-1);		
	GFXString(GRID(x,n++),(s->emul) ? "6502" : "65816",GRIDSIZE,DBGC_DATA,-1);		
	GFXNumber(GRID(x,n++),s->pbr,16,2,GRIDSIZE,DBGC_DATA,-1);		
	GFXNumber(GRID(x,n++),s->dbr,16,2,GRIDSIZE,DBGC_DATA,-1);		
	GFXNumber(GRID(x,n++),s->dpr,16,4,GRIDSIZE,DBGC_DATA,-1);		
	GFXNumber(GRID(x,n),address[3] >> 16,16,2,GRIDSIZE,DBGC_DATA,-1);		
	GFXString(GRID(x+2,n),":",GRIDSIZE,DBGC_DATA,-1);
	GFXNumber(GRID(x+3,n),address[3] & 0xFFFF,16,4,GRIDSIZE,DBGC_DATA,-1);		

	int pc = address[0];
	for (int y = 0;y < 18;y++) {
		int isBrk = (pc == address[3]);
		GFXNumber(GRID(1,y),pc >> 16,16,2,GRIDSIZE,DBGC_ADDRESS,-1);		
		GFXString(GRID(3,y),":",GRIDSIZE,DBGC_ADDRESS,-1);
		GFXNumber(GRID(4,y),pc & 0xFFFF,16,4,GRIDSIZE,DBGC_ADDRESS,-1);		
		char buffer[64],*p = (char *)opcodes[CPURead(pc++)],*q = buffer;
		while (*p != '\0') {
			if (*p == '%') {
				int c = *(p+1)-'0';
				if (*(p+1) == 'm') c = (s->p & P_65816_M) ? 1 : 2;
				if (*(p+1) == 'x') c = (s->p & P_65816_X) ? 1 : 2;
				p = p + 2;
				int newPC = pc;
				while (c-- > 0) {
					sprintf(q,"%02x",CPURead(pc+c));
					newPC++;q = q + 2;
				}
				pc = newPC;
			} else {
				*q++ = *p++;
			}
		}
		*q = '\0';
		GFXString(GRID(9,y),buffer,GRIDSIZE,isBrk ? DBGC_HIGHLIGHT:DBGC_DATA,-1);
	}

	for (int y = 20;y < 28;y++) {
		int base = address[1] + (y - 20) * 8;		
		int x = 1;
		GFXNumber(GRID(x,y),base >> 16,16,2,GRIDSIZE,DBGC_ADDRESS,-1);		
		GFXString(GRID(x+2,y),":",GRIDSIZE,DBGC_ADDRESS,-1);
		GFXNumber(GRID(x+3,y),base & 0xFFFF,16,4,GRIDSIZE,DBGC_ADDRESS,-1);		
		for (int n = 0;n < 8;n++) {
			int b = CPURead(base+n);
			GFXNumber(GRID(x+9+n*3,y),b,16,2,GRIDSIZE,DBGC_DATA,-1);		
			b = ((b & 0x7F) < 32) ? '.' : (b & 0x7F);
			GFXCharacter(GRID(x+34+n,y),b,GRIDSIZE,DBGC_DATA,-1);
		}
	}

	int xs = 64;
	int ys = 32;
	renderCount++;
	if (showDisplay) {
		int size = 2;
		int x1 = WIN_WIDTH/2-xs*size*8/2;
		int y1 = WIN_HEIGHT/2-ys*size*8/2;
		SDL_Rect r;
		int b = 16;
		r.x = x1-b;r.y = y1-b;r.w = xs*size*8+b*2;r.h=ys*size*8+b*2;
		GFXRectangle(&r,0xFFFF);
		b = b - 4;
		r.x = x1-b;r.y = y1-b;r.w = xs*size*8+b*2;r.h=ys*size*8+b*2;
		GFXRectangle(&r,0);
		for (int x = 0;x < xs;x++) 
		{
			for (int y = 0;y < ys;y++)
			{
				int ch = CPURead(0xF0000+x+y*xs);
				int rvs = (ch & 0x80) ? 0xFF:0x00;
				ch = ch & 0x7F;
				int xc = x1 + x * 8 * size;
				int yc = y1 + y * 8 * size;
				//if (renderCount & 32) rvs = 0;
				SDL_Rect rc;
				int cp = ch * 8;
				rc.w = rc.h = size;																// Width and Height of pixel.
				for (int x = 0;x < 8;x++) {														// 5 Across
					rc.x = xc + x * size;
					for (int y = 0;y < 8;y++) {													// 7 Down
						int f = font[cp+y] ^ rvs;
						rc.y = yc + y * size;
						if (f & (0x01 << x)) {		
							GFXRectangle(&rc,rvs ? 0x0FF:0x0F0);			
						}
					}
				}
			}
		}
	}
}	
