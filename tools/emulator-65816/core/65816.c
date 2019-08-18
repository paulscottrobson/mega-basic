// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//      Name:       65816.c
//      Purpose:    Wrapper for VICE 65816 emulator source
//      Created:    17th April 2019
//      Author:     Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

// *******************************************************************************************
//
//          Changes made to 65816core.c to hack out a lot of the unwanted stuff
//
// Remove 3 pseudo ops IRQ NMI RES
// Replace DO_INTERRUPT IMPORT_REGISTERS EXPORT_REGISTERS with dummy values.
//
// *******************************************************************************************

#include "65816.h"

// *******************************************************************************************
//
//                  These are the physical registers manipulated by emulation
//
// *******************************************************************************************

union regs {
     uint16_t reg_s;
     uint8_t reg_q[2];
} regs65802;

#define reg_c regs65802.reg_s

#ifndef WORDS_BIGENDIAN
#define reg_a regs65802.reg_q[0]
#define reg_b regs65802.reg_q[1]
#else
#define reg_a regs65802.reg_q[1]
#define reg_b regs65802.reg_q[0]
#endif

    uint32_t last_opcode_addr;
    uint32_t clock = 0;
    uint16_t reg_x = 0;
    uint16_t reg_y = 0;
    uint8_t reg_pbr = 0;
    uint8_t reg_dbr = 0;
    uint16_t reg_dpr = 0;
    uint8_t reg_p = 0;
    uint16_t reg_sp = 0x100;
    uint8_t flag_n = 0;
    uint8_t flag_z = 0;
    uint8_t reg_emul = 1;
    int interrupt65816 = 0;
    unsigned int reg_pc;
//    reg_c = 0;


#define GLOBAL_REGS exported                            // Used for EXPORT_REGISTERS()

REGISTERSET exported;                                   // where they go

#define STATIC_ASSERT(x) {}                             // hacks to make things compile.
#define OPINFO_SET(a,b,c,d,e) {}

#define IK_RESET    (0)
#define IK_NMI      (0)
#define IK_IRQ      (0)
#define IK_IRQPEND  (0)
#define IK_NONE     (0)

#define LAST_OPCODE_ADDR last_opcode_addr

#define ROM_TRAP_HANDLER() 0
#define STP_65816() {}                                  // Do not support STP WAI COP or any
#define WAI_65816() {}                                  // actual interrupt.
#define COP_65816(value) {}

#define ROM_TRAP_ALLOWED() (0)

#define JUMP(addr) {}                                   // Notification, *not* actual execution.

void CPU65816ExecuteOneInstruction(void)
{
        #include "65816core.c"
}

void CPU65816GetStatus(REGISTERSET *status) {
    EXPORT_REGISTERS();
    *status = exported;
}

int CPU65816GetPC(void) {
    return reg_pc | (reg_pbr << 16);
}

int CPU65816GetBank(void) {
    return reg_pbr << 16;
}

void CPU65816Reset(void) {
    reg_pbr = reg_dpr = reg_dbr = 0;
    reg_pc = LOAD_LONG(0xFFFC)+LOAD_LONG(0xFFFD) * 256;
    reg_emul = 1;    
}