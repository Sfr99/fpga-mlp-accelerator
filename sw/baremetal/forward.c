#include <math.h>
#include "forward.h"
#include "weights.h"

// Multiplicación Matriz-Vector con bias
void dot_prod(const float *pesos, const float *v_entrada, const float *bias,
                float * v_salida, int f, int c){
    for (int i = 0; i < f; i++) {
        v_salida[i] = bias[i];
        for (int j = 0; j < c; j++) {
            v_salida[i] += pesos[i*c + j] * v_entrada[j];
        }
    }
}

// Función ReLU
void relu(const float *v_entrada, float *v_salida, int tam){
    for (int i = 0; i < tam; i++) {
        v_salida[i] = v_entrada[i] > 0 ? v_entrada[i] : 0;
    }
}

// Función Softmax
void softmax(const float *v_entrada, float *v_salida, int tam) {
    float acum = 0;
    float max = v_entrada[0];

    for (int i = 0; i < tam; i++){
        if (v_entrada[i] > max) max = v_entrada[i];
    }
    for (int i = 0; i < tam; i++){
        acum += expf(v_entrada[i]-max);
    }

    for (int j = 0; j < tam; j++){
        v_salida[j] = expf(v_entrada[j]-max)/acum;
    }
}

// función forward que encadena las tres capas
void forward(const float *v_entrada, float *v_salida){
    dot_prod(m_pesos_0, v_entrada, v_bias_0, ibuf0, 32, 200);
    relu(ibuf0, ibuf0, 32);

    dot_prod(m_pesos_1, ibuf0, v_bias_1, ibuf1, 16, 32);
    relu(ibuf1, ibuf1, 16);

    dot_prod(m_pesos_2, ibuf1, v_bias_2, ibuf0, 16, 16);

    softmax(ibuf0, v_salida, 16);
}