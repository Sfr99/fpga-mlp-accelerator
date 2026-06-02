# script para generar el fichero test.h a partir de los datos de test y el modelo entrenado
import numpy as np
import torch
import torch.nn as nn

class HYPER(nn.Module):
    def __init__(self, num_in, num_out):
        super().__init__()

        # Capas del modelo
        self.l = torch.nn.Sequential(
            nn.Linear(num_in, 32),
            nn.ReLU(),
            nn.Linear(32, 16),
            nn.ReLU(),
            nn.Linear(16, num_out),
            nn.Softmax(dim=1)
        )

    # Funcion para ejecutar el modelo
    def forward(self, x):
        x = self.l(x)
        return x


if __name__ == "__main__":

    data = np.load("../ejemplos_redes/ejemplo_py/Data/IP.npz")
    first = data["test_data"][0]
    
    model = HYPER(200, 16)
    weights = torch.load("../ejemplos_redes/ejemplo_py/IP.pth")
    model.load_state_dict(weights)

    tensor = torch.tensor(first).float().unsqueeze(0)
    output = model(tensor)
    
    with open("../src/test.h", "w") as f:
        f.write("//FICHERO GENERADO AUTOMATICAMENTE, NO MODIFICAR\n\n#ifndef TEST_H\n#define TEST_H\n\n")
        input_str = ", ".join(f"{v}f" for v in first)
        f.write(f"const float test_input[200] = {{{input_str}}};\n\n")
        output_str = ", ".join(f"{v}f" for v in output.detach().numpy()[0])
        f.write(f"const float test_output[16] = {{{output_str}}};\n\n")
        f.write("#endif //TEST_H\n")

    print("test.h generado en ../src/test.h")