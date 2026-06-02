#include "pmu.h"

void pmu_init(void) {
    unsigned int pmcr;
    asm volatile("mrc p15, 0, %0, c9, c12, 0" : "=r"(pmcr));
    pmcr |= 1;
    pmcr &= ~8;
    asm volatile("mcr p15, 0, %0, c9, c12, 0" :: "r"(pmcr));
    asm volatile("mcr p15, 0, %0, c9, c12, 1" :: "r"(0x80000000));
    asm volatile("mcr p15, 0, %0, c9, c12, 0" :: "r"(pmcr | 4));
}

unsigned int pmu_read(void) {
    unsigned int val;
    asm volatile("mrc p15, 0, %0, c9, c13, 0" : "=r"(val));
    return val;
}

double pmu_cycles_to_us(unsigned int ciclos) {
    return (double)ciclos / 666.666687;
}