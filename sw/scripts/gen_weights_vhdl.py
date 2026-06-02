# script para generar un package VHDL con un tipo peso_array genérico y una constante por cada 
# capa de pesos y bias, todo en formato hexa 16 bits con signo.
import torch
import numpy as np

def cuantizar(arr):
    """Float -> punto fijo 8.8 (int16)"""
    return np.clip(np.round(arr * 256), -32768, 32767).astype(np.int16)

def to_hex16(val):
    """int16 -> string hex 4 dígitos (complemento a 2)"""
    return f'x"{int(val) & 0xFFFF:04X}"'

dic = torch.load("../ejemplos_redes/ejemplo_py/IP.pth")

capas = [
    ("l.0.weight", "PESOS_0", 32, 200),
    ("l.0.bias",   "BIAS_0",  32, 1),
    ("l.2.weight", "PESOS_1", 16, 32),
    ("l.2.bias",   "BIAS_1",  16, 1),
    ("l.4.weight", "PESOS_2", 16, 16),
    ("l.4.bias",   "BIAS_2",  16, 1),
]

with open("../src/weights_pkg.vhd", "w") as f:
    f.write("-- FICHERO GENERADO AUTOMATICAMENTE, NO MODIFICAR\n")
    f.write("library IEEE;\n")
    f.write("use IEEE.STD_LOGIC_1164.ALL;\n")
    f.write("use IEEE.NUMERIC_STD.ALL;\n\n")
    f.write("package weights_pkg is\n\n")
    f.write("    type peso_array is array(natural range <>) of signed(15 downto 0);\n\n")

    for clave, nombre, filas, cols in capas:
        valores = cuantizar(dic[clave].numpy().flatten())
        total = len(valores)
        hex_str = ", ".join(to_hex16(v) for v in valores)
        f.write(f"    constant {nombre} : peso_array(0 to {total - 1}) := ({hex_str});\n\n")

    f.write("end package weights_pkg;\n")

print("weights_pkg.vhd generado en ../vhdl/weights_pkg.vhd")