# Script para converter binário em arquivo .hex para inicialização da RAM
import sys

if len(sys.argv) != 3:
    print("Uso: python3 mem_init.py <input.bin> <output.hex>")
    sys.exit(1)

with open(sys.argv[1], 'rb') as f:
    data = f.read()

with open(sys.argv[2], 'w') as f:
    for i in range(0, len(data), 4):
        word = data[i:i+4].ljust(4, b'\x00')
        f.write('{:02x}{:02x}{:02x}{:02x}\n'.format(word[3], word[2], word[1], word[0]))
