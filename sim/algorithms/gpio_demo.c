// Demonstração de controle dos periféricos GPIO/Analógico/Servo do RISCuinho-NG
// Assuma mapeamento:
// - LED Matrix: 8x8 bytes em 0x90000000
// - Botões: 16 bits em 0x90000080
// - Analógico: 8 bytes em 0x90000090
// - Servo: 4 bytes em 0x900000A0
#define LED_MATRIX ((volatile unsigned char*)0x90000000)
#define BTN_MATRIX ((volatile unsigned char*)0x90000080)
#define ANALOG_IN  ((volatile unsigned char*)0x90000090)
#define SERVO_OUT  ((volatile unsigned char*)0x900000A0)

void delay(int x) { for (volatile int i=0; i<x*10000; ++i); }

void fade_star() {
    // Desenha estrela com fade-in/out
    unsigned char star[8] = {0x81,0x42,0x24,0x18,0x18,0x24,0x42,0x81};
    for (int fade=0; fade<16; ++fade) {
        for (int r=0; r<8; ++r) LED_MATRIX[r] = (star[r]*fade)/15;
        delay(30);
    }
    for (int fade=15; fade>=0; --fade) {
        for (int r=0; r<8; ++r) LED_MATRIX[r] = (star[r]*fade)/15;
        delay(30);
    }
}

void anim_circ() {
    // Anima "circuito" crescendo/diminuindo
    for (int rad=1; rad<5; ++rad) {
        for (int r=0; r<8; ++r) {
            unsigned char row=0;
            for (int c=0; c<8; ++c) {
                int dx=r-3, dy=c-3;
                if (dx*dx+dy*dy<rad*rad+1) row|=1<<c;
            }
            LED_MATRIX[r]=row;
        }
        delay(50);
    }
    for (int rad=4; rad>0; --rad) {
        for (int r=0; r<8; ++r) {
            unsigned char row=0;
            for (int c=0; c<8; ++c) {
                int dx=r-3, dy=c-3;
                if (dx*dx+dy*dy<rad*rad+1) row|=1<<c;
            }
            LED_MATRIX[r]=row;
        }
        delay(50);
    }
}

void main() {
    // Inicialização: animações
    fade_star();
    anim_circ();
    // Loop principal
    while (1) {
        // 1. Espelha botões nos LEDs
        unsigned short btns = ((unsigned short*)BTN_MATRIX)[0];
        for (int r=0; r<4; ++r)
            for (int c=0; c<4; ++c)
                LED_MATRIX[r][c] = (btns & (1<<(r*4+c))) ? 0xFF : 0x00;
        // 2. Potenciômetros controlam servos
        for (int i=0; i<4; ++i) SERVO_OUT[i] = ANALOG_IN[i];
        // 3. Potenciômetros extras animam matriz
        int t = ANALOG_IN[4];
        for (int r=0; r<8; ++r)
            for (int c=0; c<8; ++c)
                LED_MATRIX[r][c] = ((r+c+t/8)%8)<(t/32) ? 0xFF : 0x00;
        delay(10);
    }
}
