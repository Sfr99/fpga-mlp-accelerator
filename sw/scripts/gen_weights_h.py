# script para generar el fichero weights.h a partir de los pesos del modelo entrenado
import torch
import numpy as np

dic = torch.load("../ejemplos_redes/ejemplo_py/IP.pth")

with open("../src/weights.h", "w") as f: 
    f.write("//FICHERO GENERADO AUTOMATICAMENTE, NO MODIFICAR\n\n#ifndef WEIGHTS_H\n#define WEIGHTS_H\n\n")

    valores = dic["l.0.weight"].numpy().flatten().tolist()
    weights_str = ", ".join(f"{v}f" for v in valores)

    f.write(f"const float m_pesos_0[32*200] = {{{weights_str}}};\n\n")
    valores = dic["l.2.weight"].numpy().flatten().tolist()
    weights_str = ", ".join(f"{v}f" for v in valores)

    f.write(f"const float m_pesos_1[16*32] = {{{weights_str}}};\n\n")

    valores = dic["l.4.weight"].numpy().flatten().tolist()
    weights_str = ", ".join(f"{v}f" for v in valores)

    f.write(f"const float m_pesos_2[16*16] = {{{weights_str}}};\n\n")

    valores = dic["l.0.bias"].numpy().flatten().tolist()
    weights_str = ", ".join(f"{v}f" for v in valores)

    f.write(f"const float v_bias_0[32] = {{{weights_str}}};\n\n")

    valores = dic["l.2.bias"].numpy().flatten().tolist()
    weights_str = ", ".join(f"{v}f" for v in valores)

    f.write(f"const float v_bias_1[16] = {{{weights_str}}};\n\n")

    valores = dic["l.4.bias"].numpy().flatten().tolist()
    weights_str = ", ".join(f"{v}f" for v in valores)

    f.write(f"const float v_bias_2[16] = {{{weights_str}}};\n\n")

    f.write("#endif //WEIGHTS_H\n")

print("weights.h generado en ../src/weights.h")