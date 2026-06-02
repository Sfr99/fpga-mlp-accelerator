# gen_test_vhdl.py
import numpy as np
import torch

def cuantizar(arr):
    return np.clip(np.round(arr * 256), -32768, 32767).astype(np.int16)

def to_hex16(val):
    return f'x"{int(val) & 0xFFFF:04X}"'

data = np.load("../ejemplos_redes/ejemplo_py/Data/IP.npz")
first = cuantizar(data["test_data"][0].astype(np.float32))

with open("../vhdl/test_pkg.vhd", "w") as f:
    f.write("-- FICHERO GENERADO AUTOMATICAMENTE, NO MODIFICAR\n")
    f.write("library IEEE;\n")
    f.write("use IEEE.STD_LOGIC_1164.ALL;\n")
    f.write("use IEEE.NUMERIC_STD.ALL;\n")
    f.write("use work.weights_pkg.ALL;\n\n")  
    f.write("package test_pkg is\n\n")
    hex_str = ", ".join(to_hex16(v) for v in first)
    f.write(f"    constant TEST_INPUT : peso_array(0 to 199) := ({hex_str});\n\n")
    f.write("end package test_pkg;\n")

print("test_pkg.vhd generado")