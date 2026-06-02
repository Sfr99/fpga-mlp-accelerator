#include <xil_io.h>
#include <xil_printf.h>
#include <math.h>
#include <stdio.h>
#include <stdint.h>
#include "pmu.h"
#include "test.h"
#include "forward.h"

#define BASE_ADDR     0x43C00000
#define REG_DATA      0x00
#define REG_CTRL      0x04
#define REG_STATUS    0x08
#define REG_PL_CYCLES 0x0C
#define REG_OUT_BASE  0x20

int test_hw(unsigned int *ciclos_roundtrip, unsigned int *ciclos_pl){
    // Reset edge detector
    Xil_Out32(BASE_ADDR + REG_CTRL, 0);
    Xil_In32(BASE_ADDR + REG_CTRL);

    unsigned int start = pmu_read();

    // Enviar 200 entradas (2 por escritura, 100 escrituras)
    for(int i = 0; i < 100; i++){
        int16_t low  = (int16_t)roundf(test_input[i*2] * 256.0f);
        int16_t high = (int16_t)roundf(test_input[i*2+1] * 256.0f);
        u32 pack = ((u32)(u16)high << 16) | (u16)low;
        Xil_Out32(BASE_ADDR + REG_DATA, pack);
    }

    // Arrancar acelerador y esperar done
    Xil_Out32(BASE_ADDR + REG_CTRL, 1);
    while((Xil_In32(BASE_ADDR + REG_STATUS) & 0x1) == 0) {}

    // Leer 16 salidas (2 por registro, 8 lecturas)
    int16_t res[16];
    for(int i = 0; i < 8; i++){
        u32 reg = Xil_In32(BASE_ADDR + REG_OUT_BASE + i*4);
        res[i*2]   = (int16_t)(reg & 0xFFFF);
        res[i*2+1] = (int16_t)(reg >> 16);
    }

    unsigned int end = pmu_read();

    *ciclos_roundtrip = end - start;
    *ciclos_pl = Xil_In32(BASE_ADDR + REG_PL_CYCLES);

    // Argmax
    int max_idx = 0;
    for(int i = 1; i < 16; i++)
        if(res[i] > res[max_idx]) max_idx = i;

    return max_idx;
}

int test_sw(unsigned int *ciclos_sw){
    float output[16];

    unsigned int start = pmu_read();
    forward(test_input, output);
    unsigned int end = pmu_read();

    *ciclos_sw = end - start;

    // Argmax
    int max_idx = 0;
    for(int i = 1; i < 16; i++)
        if(output[i] > output[max_idx]) max_idx = i;

    return max_idx;
}

int main(){
    pmu_init();

    // Calibración de frecuencias
    u32 dbg1 = Xil_In32(BASE_ADDR + 0x10);
    unsigned int pmu1 = pmu_read();
    for(volatile int i = 0; i < 100000; i++){}
    u32 dbg2 = Xil_In32(BASE_ADDR + 0x10);
    unsigned int pmu2 = pmu_read();
    printf("=== Calibracion ===\r\n");
    printf("Delta PMU (ARM): %u ciclos\r\n", pmu2 - pmu1);
    printf("Delta debug (PL): %lu ciclos\r\n", dbg2 - dbg1);
    printf("Ratio ARM/PL: %.2f (esperado ~6.66)\r\n", (double)(pmu2 - pmu1) / (double)(dbg2 - dbg1));
    printf("\r\n");

    // Tests
    unsigned int ciclos_roundtrip, ciclos_pl, ciclos_sw;
    int clase_hw = test_hw(&ciclos_roundtrip, &ciclos_pl);
    int clase_sw = test_sw(&ciclos_sw);

    double t_pl    = (double)ciclos_pl / 100.0;
    double t_rt    = pmu_cycles_to_us(ciclos_roundtrip);
    double t_sw    = pmu_cycles_to_us(ciclos_sw);
    double t_total = t_pl + t_rt;

    printf("=== Resultados ===\r\n");
    printf("Clase HW: %d | Clase SW: %d\r\n", clase_hw, clase_sw);
    printf("\r\n");
    printf("ARM SW (-O2):   %5u ciclos @ 666MHz  (%5.2f us)\r\n", ciclos_sw, t_sw);
    printf("PL computo:     %5lu ciclos @ 100MHz  (%5.2f us)\r\n", ciclos_pl, t_pl);
    printf("AXI overhead:   %5u ciclos @ 666MHz  (%5.2f us)\r\n", ciclos_roundtrip, t_rt);
    printf("HW total (PL + AXI):                   (%5.2f us)\r\n", t_total);
    printf("\r\n");
    printf("Speedup PL puro vs ARM:    %.2fx\r\n", t_sw / t_pl);
    printf("Speedup HW total vs ARM:   %.2fx\r\n", t_sw / t_total);

    return 0;
}