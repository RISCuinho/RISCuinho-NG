#!/usr/bin/env python3
import os
import time
import threading
import sys
import termios
import tty

IN_FILE = os.path.join(os.path.dirname(__file__), 'rs232.in')
OUT_FILE = os.path.join(os.path.dirname(__file__), 'rs232.out')

# Terminal VT100-like: envia teclas para rs232.in, mostra saída de rs232.out

def read_stdin_to_infile():
    """Captura teclado e envia para o hardware (rs232.in)"""
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        while True:
            c = sys.stdin.read(1)
            if c == '\x03':  # Ctrl-C
                break
            with open(IN_FILE, 'w') as f:
                f.write(c)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)

def tail_outfile():
    """Mostra em tempo real o que for enviado pelo hardware (rs232.out)"""
    last_size = 0
    while True:
        if os.path.exists(OUT_FILE):
            with open(OUT_FILE, 'r') as f:
                f.seek(last_size)
                data = f.read()
                if data:
                    print(data, end='', flush=True)
                last_size = f.tell()
        time.sleep(0.05)

def main():
    print('\033[2J\033[H', end='')  # Limpa tela VT100
    print('RISCuinho RS232 Terminal (Ctrl-C para sair)')
    t = threading.Thread(target=tail_outfile, daemon=True)
    t.start()
    try:
        read_stdin_to_infile()
    except KeyboardInterrupt:
        pass
    print('\nTerminal encerrado.')

if __name__ == '__main__':
    main()
