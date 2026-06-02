# test de la red con pesos y datos cuantizados a 8.8 (int16) para simular la implementación en FPGA
import torch
import numpy as np

def cuantizar(arr):
    """Float -> punto fijo 8.8 (int16)"""
    return np.clip(np.round(arr * 256), -32768, 32767).astype(np.int16)

def dot_prod_quant(pesos, entrada, bias, f, c):
    """Dot product en aritmética entera 8.8"""
    salida = np.zeros(f, dtype=np.int16)
    for i in range(f):
        # Acumulador de 48 bits (como el DSP48E1)
        acc = np.int64(bias[i]) << 8  # bias está en 8.8, acumulador en 16.16
        for j in range(c):
            acc += np.int64(pesos[i * c + j]) * np.int64(entrada[j])  # 8.8 × 8.8 = 16.16
        # Truncar de 16.16 a 8.8: desplazar 8 bits a la derecha
        resultado = acc >> 8
        salida[i] = np.clip(resultado, -32768, 32767).astype(np.int16)
    return salida

def relu_quant(entrada):
    return np.where(entrada > 0, entrada, np.int16(0))

def forward_quant(entrada, pesos_0, bias_0, pesos_1, bias_1, pesos_2, bias_2):
    x = dot_prod_quant(pesos_0, entrada, bias_0, 32, 200)
    x = relu_quant(x)
    x = dot_prod_quant(pesos_1, x, bias_1, 16, 32)
    x = relu_quant(x)
    x = dot_prod_quant(pesos_2, x, bias_2, 16, 16)
    # No softmax — solo nos interesa el argmax (la clase predicha)
    return x

if __name__ == "__main__":
    # Cargar pesos y cuantizar
    dic = torch.load("../ejemplos_redes/ejemplo_py/IP.pth")
    p0 = cuantizar(dic["l.0.weight"].numpy().flatten())
    b0 = cuantizar(dic["l.0.bias"].numpy().flatten())
    p1 = cuantizar(dic["l.2.weight"].numpy().flatten())
    b1 = cuantizar(dic["l.2.bias"].numpy().flatten())
    p2 = cuantizar(dic["l.4.weight"].numpy().flatten())
    b2 = cuantizar(dic["l.4.bias"].numpy().flatten())

    # Test con un dato
    data = np.load("../ejemplos_redes/ejemplo_py/Data/IP.npz")
    first = cuantizar(data["test_data"][0].astype(np.float32))

    salida = forward_quant(first, p0, b0, p1, b1, p2, b2)
    clase = np.argmax(salida)
    print(f"Clase predicha (cuantizado): {clase}")
    print(f"Salida: {salida}")
    capa1 = dot_prod_quant(p0, first, b0, 32, 200)
    print(f"Neurona 0, capa 1 (antes de ReLU): {capa1[0]}")
    capa1_relu = relu_quant(capa1)
    print(f"Capa 1 tras ReLU (32 valores): {list(capa1_relu)}")
    # Test con todo el dataset
    test_data = data["test_data"].astype(np.float32)
    test_targets = data["test_targets"]
    correctos = 0
    total = len(test_data)
    for i in range(total):
        entrada = cuantizar(test_data[i])
        salida = forward_quant(entrada, p0, b0, p1, b1, p2, b2)
        if np.argmax(salida) == test_targets[i]:
            correctos += 1

    accuracy = correctos / total * 100
    print(f"\nAccuracy float32: 82.71%")
    print(f"Accuracy 8.8:     {accuracy:.2f}%")
    print(f"Diferencia:       {82.71 - accuracy:.2f}%")