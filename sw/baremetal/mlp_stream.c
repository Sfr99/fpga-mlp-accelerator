#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include "xaxidma.h"
#include "xparameters.h"
#include "xil_cache.h"
#include "xil_io.h"
#include "pmu.h"
#include "test.h"
#include "forward.h"

#define DMA_BASE_ADDR    XPAR_XAXIDMA_0_BASEADDR
#define ACCEL_BASE       0x43C00000
#define REG_NUMCYCLES    0x08

#define NUM_INPUT_WORDS  100
#define NUM_OUTPUT_WORDS 8

static u32 tx_buffer[NUM_INPUT_WORDS]  __attribute__((aligned(64)));
static u32 rx_buffer[NUM_OUTPUT_WORDS] __attribute__((aligned(64)));

XAxiDma dma;

int test_hw(unsigned int *ciclos_total) {
    int status;

    for (int i = 0; i < NUM_INPUT_WORDS; i++) {
        int16_t low  = (int16_t)roundf(test_input[i*2]     * 256.0f);
        int16_t high = (int16_t)roundf(test_input[i*2 + 1] * 256.0f);
        tx_buffer[i] = ((u32)(u16)high << 16) | (u16)low;
    }
    for (int i = 0; i < NUM_OUTPUT_WORDS; i++) rx_buffer[i] = 0;

    Xil_DCacheFlushRange((UINTPTR)tx_buffer, NUM_INPUT_WORDS  * sizeof(u32));
    Xil_DCacheFlushRange((UINTPTR)rx_buffer, NUM_OUTPUT_WORDS * sizeof(u32));

    unsigned int t_start = pmu_read();

    status = XAxiDma_SimpleTransfer(&dma, (UINTPTR)rx_buffer,
                                    NUM_OUTPUT_WORDS * sizeof(u32),
                                    XAXIDMA_DEVICE_TO_DMA);
    if (status != XST_SUCCESS) return -1;

    status = XAxiDma_SimpleTransfer(&dma, (UINTPTR)tx_buffer,
                                    NUM_INPUT_WORDS * sizeof(u32),
                                    XAXIDMA_DMA_TO_DEVICE);
    if (status != XST_SUCCESS) return -1;

    while (XAxiDma_Busy(&dma, XAXIDMA_DMA_TO_DEVICE)) {}
    while (XAxiDma_Busy(&dma, XAXIDMA_DEVICE_TO_DMA)) {}

    unsigned int t_end = pmu_read();
    *ciclos_total = t_end - t_start;

    Xil_DCacheInvalidateRange((UINTPTR)rx_buffer, NUM_OUTPUT_WORDS * sizeof(u32));

    int16_t res[16];
    for (int i = 0; i < NUM_OUTPUT_WORDS; i++) {
        res[i*2]     = (int16_t)(rx_buffer[i] & 0xFFFF);
        res[i*2 + 1] = (int16_t)(rx_buffer[i] >> 16);
    }
    int max_idx = 0;
    for (int i = 1; i < 16; i++)
        if (res[i] > res[max_idx]) max_idx = i;

    return max_idx;
}

int test_sw(unsigned int *ciclos_sw){
    float output[16];

    unsigned int start = pmu_read();
    forward(test_input, output);
    unsigned int end = pmu_read();

    *ciclos_sw = end - start;

    int max_idx = 0;
    for(int i = 1; i < 16; i++)
        if(output[i] > output[max_idx]) max_idx = i;

    return max_idx;
}

int main() {
    pmu_init();

    XAxiDma_Config *cfg = XAxiDma_LookupConfig(DMA_BASE_ADDR);
    if (!cfg) { printf("DMA config lookup failed\r\n"); return -1; }
    if (XAxiDma_CfgInitialize(&dma, cfg) != XST_SUCCESS) {
        printf("DMA init failed\r\n"); return -1;
    }
    XAxiDma_IntrDisable(&dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
    XAxiDma_IntrDisable(&dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

    // Calibracion de frecuencias
    u32 dbg1 = Xil_In32(ACCEL_BASE + REG_NUMCYCLES);
    unsigned int pmu1 = pmu_read();
    for(volatile int i = 0; i < 100000; i++){}
    u32 dbg2 = Xil_In32(ACCEL_BASE + REG_NUMCYCLES);
    unsigned int pmu2 = pmu_read();
    unsigned int delta_pmu = pmu2 - pmu1;
    u32 delta_pl = dbg2 - dbg1;
    double ratio = (double)delta_pmu / (double)delta_pl;

    printf("=== Calibracion ===\r\n");
    printf("Delta PMU (ARM): %u ciclos\r\n", delta_pmu);
    printf("Delta PL:        %lu ciclos\r\n", delta_pl);
    printf("Ratio ARM/PL:    %.2f (esperado ~6.66)\r\n", ratio);
    printf("\r\n");

    // Tests
    unsigned int ciclos_hw, ciclos_sw;
    int clase_hw = test_hw(&ciclos_hw);
    int clase_sw = test_sw(&ciclos_sw);
    if (clase_hw < 0) { printf("HW test failed\r\n"); return -1; }

    double t_hw = pmu_cycles_to_us(ciclos_hw);
    double t_sw = pmu_cycles_to_us(ciclos_sw);

    printf("=== Resultados ===\r\n");
    printf("Clase HW: %d | Clase SW: %d\r\n", clase_hw, clase_sw);
    printf("\r\n");
   printf("ARM SW (-O2):   %5u ciclos ARM (%6.2f us)\r\n", ciclos_sw, t_sw);
    printf("HW (DMA + PL):  %5u ciclos ARM (%6.2f us)\r\n", ciclos_hw, t_hw);
    printf("\r\n");
    printf("Speedup HW vs ARM: %.2fx\r\n", t_sw / t_hw);
    printf("=== Fin ===\r\n");

    return 0;
}