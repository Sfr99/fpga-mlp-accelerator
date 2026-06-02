#ifndef PMU_H
#define PMU_H

void pmu_init(void);
unsigned int pmu_red(void);
double pmu_cycles_to_us(unsigned int cycles);

#endif // PMU_H