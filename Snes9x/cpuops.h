#ifndef _CPUOPS_H_
#define _CPUOPS_H_

void S9xOpcode_NMI (void);
void S9xOpcode_IRQ (void);

#ifndef SA1_OPCODES
#define CHECK_FOR_IRQ() {} // if (CPU.IRQLine) S9xOpcode_IRQ(); }
#else
#define CHECK_FOR_IRQ()	{}
#endif
#endif
