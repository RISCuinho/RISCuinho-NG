#!/usr/bin/env python3
import tkinter as tk
from tkinter import ttk
import math
import os
import threading
import time

# Arquivos simulados para comunicação com o hardware
GPIO_LED_FILE = os.path.join(os.path.dirname(__file__), 'gpio_leds.bin')
GPIO_BTN_FILE = os.path.join(os.path.dirname(__file__), 'gpio_btns.bin')
ANALOG_FILE = os.path.join(os.path.dirname(__file__), 'gpio_analog.bin')
SERVO_FILE = os.path.join(os.path.dirname(__file__), 'gpio_servo.bin')

class LedMatrix(tk.Canvas):
    def __init__(self, master, rows=8, cols=8, size=24, **kwargs):
        super().__init__(master, width=cols*size, height=rows*size, bg='black', **kwargs)
        self.rows = rows
        self.cols = cols
        self.size = size
        self.leds = [[self.create_oval(c*size+2, r*size+2, c*size+size-2, r*size+size-2, fill='gray20', outline='gray60') for c in range(cols)] for r in range(rows)]
    def set_matrix(self, bitmap):
        for r in range(self.rows):
            for c in range(self.cols):
                color = '#ff0' if bitmap[r][c] else 'gray20'
                self.itemconfig(self.leds[r][c], fill=color)
    def fade(self, val):
        for r in range(self.rows):
            for c in range(self.cols):
                color = f'#{int(val*255):02x}{int(val*255):02x}00' if val > 0 else 'gray20'
                self.itemconfig(self.leds[r][c], fill=color)

class ButtonMatrix(tk.Frame):
    def __init__(self, master, rows=4, cols=4, callback=None, **kwargs):
        super().__init__(master, **kwargs)
        self.rows = rows
        self.cols = cols
        self.callback = callback
        self.states = [[0]*cols for _ in range(rows)]
        self.btns = []
        for r in range(rows):
            row = []
            for c in range(cols):
                b = ttk.Checkbutton(self, command=lambda rr=r,cc=c:self.toggle(rr,cc))
                b.grid(row=r, column=c, padx=2, pady=2)
                row.append(b)
            self.btns.append(row)
    def toggle(self, r, c):
        self.states[r][c] = 1 if self.btns[r][c].instate(['selected']) else 0
        if self.callback:
            self.callback(self.states)
    def get_states(self):
        return self.states
    def set_states(self, states):
        for r in range(self.rows):
            for c in range(self.cols):
                if states[r][c]:
                    self.btns[r][c].state(['selected'])
                else:
                    self.btns[r][c].state(['!selected'])

class AnalogPanel(tk.Frame):
    def __init__(self, master, n=8, callback=None, **kwargs):
        super().__init__(master, **kwargs)
        self.n = n
        self.scales = []
        self.callback = callback
        for i in range(n):
            s = tk.Scale(self, from_=0, to=255, orient=tk.HORIZONTAL, label=f'A{i}', command=lambda v, idx=i:self.changed(idx,v))
            s.grid(row=i, column=0, sticky='ew')
            self.scales.append(s)
    def changed(self, idx, val):
        if self.callback:
            self.callback(self.get_values())
    def get_values(self):
        return [s.get() for s in self.scales]
    def set_values(self, vals):
        for i,v in enumerate(vals):
            self.scales[i].set(v)

class ServoPanel(tk.Frame):
    def __init__(self, master, n=4, **kwargs):
        super().__init__(master, **kwargs)
        self.n = n
        self.angles = [90]*n
        self.bars = []
        for i in range(n):
            canvas = tk.Canvas(self, width=80, height=40, bg='white')
            canvas.grid(row=i, column=0, padx=4, pady=2)
            bar = canvas.create_line(40, 35, 40+30*math.cos(math.radians(self.angles[i]-90)), 35-30*math.sin(math.radians(self.angles[i]-90)), width=6, fill='blue')
            canvas.create_oval(35,30,45,40,fill='gray')
            self.bars.append((canvas, bar))
        self.set_angles(self.angles)
    def set_angles(self, angles):
        self.angles = angles
        for i,(canvas,bar) in enumerate(self.bars):
            angle = angles[i]
            x = 40+30*math.cos(math.radians(angle-90))
            y = 35-30*math.sin(math.radians(angle-90))
            canvas.coords(bar, 40,35,x,y)

class GpioSimApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title('RISCuinho GPIO/Analog/Servo Simulator')
        self.resizable(False, False)
        # Painel de LEDs
        self.led_matrix = LedMatrix(self)
        self.led_matrix.grid(row=0, column=0, padx=8, pady=8)
        # Painel de botões
        self.btn_matrix = ButtonMatrix(self, callback=self.btn_callback)
        self.btn_matrix.grid(row=0, column=1, padx=8, pady=8)
        # Painel analógico
        self.analog_panel = AnalogPanel(self, callback=self.analog_callback)
        self.analog_panel.grid(row=1, column=0, padx=8, pady=8)
        # Painel de servos
        self.servo_panel = ServoPanel(self)
        self.servo_panel.grid(row=1, column=1, padx=8, pady=8)
        # Inicialização animada
        self.after(100, self.startup_animation)
        # Thread de atualização
        self.running = True
        threading.Thread(target=self.hw_update_loop, daemon=True).start()
    def startup_animation(self):
        # Fade-in estrela
        for alpha in range(0,256,8):
            self.led_matrix.fade(alpha/255)
            self.update()
            time.sleep(0.01)
        # Desenha estrela
        star = [[0]*8 for _ in range(8)]
        for i in range(8):
            star[i][i] = 1
            star[i][7-i] = 1
        for _ in range(16):
            self.led_matrix.set_matrix(star)
            self.update()
            time.sleep(0.05)
            for i in range(8):
                star[i][i] = 0 if star[i][i] else 1
                star[i][7-i] = 0 if star[i][7-i] else 1
        # Fade-out
        for alpha in range(255,-1,-8):
            self.led_matrix.fade(alpha/255)
            self.update()
            time.sleep(0.01)
        # Circuito animado
        circ = [[0]*8 for _ in range(8)]
        for r in range(8):
            for c in range(8):
                if (r-3.5)**2 + (c-3.5)**2 < 12:
                    circ[r][c] = 1
        for _ in range(32):
            self.led_matrix.set_matrix(circ)
            self.update()
            time.sleep(0.03)
            for r in range(8):
                for c in range(8):
                    circ[r][c] = 1 if ((r-3.5)**2 + (c-3.5)**2 + time.time()*2)%2 < 1 else 0
    def btn_callback(self, states):
        # Salva estados dos botões
        flat = [x for row in states for x in row]
        with open(GPIO_BTN_FILE, 'wb') as f:
            f.write(bytes(flat))
    def analog_callback(self, values):
        # Salva valores analógicos
        with open(ANALOG_FILE, 'wb') as f:
            f.write(bytes(values))
    def hw_update_loop(self):
        while self.running:
            # Atualiza LEDs
            if os.path.exists(GPIO_LED_FILE):
                with open(GPIO_LED_FILE, 'rb') as f:
                    data = f.read(8)
                bitmap = [[(data[r] >> (7-c))&1 for c in range(8)] for r in range(8)]
                self.led_matrix.set_matrix(bitmap)
            # Atualiza servos
            if os.path.exists(SERVO_FILE):
                with open(SERVO_FILE, 'rb') as f:
                    data = f.read(4)
                angles = [min(180,max(0,int(x))) for x in data]
                self.servo_panel.set_angles(angles)
            time.sleep(0.05)
    def on_close(self):
        self.running = False
        self.destroy()

if __name__ == '__main__':
    app = GpioSimApp()
    app.protocol('WM_DELETE_WINDOW', app.on_close)
    app.mainloop()
