#ifndef FORWARD_H
#define FORWARD_H

// buffers intermedios entre capas
static float ibuf0[32];
static float ibuf1[16];

// Multiplicación Matriz-Vector con bias
void dot_prod(const float *pesos, const float *v_entrada, const float *bias,
                float * v_salida, int f, int c);

// Función ReLU
void relu(const float *v_entrada, float *v_salida, int tam);

// Función Softmax
void softmax(const float *v_entrada, float *v_salida, int tam);

// función forward que encadena las tres capas
void forward(const float *v_entrada, float *v_salida);

#endif // FORWARD_H