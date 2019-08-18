// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//      Name:       65816.h
//      Purpose:    Wrapper for VICE 65816 emulator source, include file.
//      Created:    17th April 2019
//      Author:     Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#ifndef WRAP65816
#define WRAP65816

#define P_SIGN          0x80
#define P_OVERFLOW      0x40
#define P_UNUSED        0x20
#define P_65816_M       0x20
#define P_65816_X       0x10
#define P_BREAK         0x10
#define P_DECIMAL       0x08
#define P_INTERRUPT     0x04
#define P_ZERO          0x02
#define P_CARRY         0x01

typedef unsigned short uint16_t;
typedef unsigned char uint8_t;
typedef unsigned int uint32_t;

typedef struct __registerset {
      uint16_t pc;     
      uint16_t a;       
      uint16_t b;       
      uint16_t x;       
      uint16_t y;       
      uint16_t emul; 
      uint16_t dpr;   
      uint16_t pbr;   
      uint16_t dbr;   
      uint16_t sp;     
      uint16_t p;       
      uint16_t n;      
      uint16_t z;          
} REGISTERSET;

void CPU65816ExecuteOneInstruction(void);
void CPU65816GetStatus(REGISTERSET *status);
int CPU65816GetPC(void);
int CPU65816GetBank(void);
void CPU65816Reset(void);
#endif
