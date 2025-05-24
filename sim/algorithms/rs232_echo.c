// Exemplo de uso da porta RS232 no RISCuinho-NG
#define RS232_ADDR (*(volatile unsigned char*)0x80000000)

void main() {
    unsigned char c;
    while (1) {
        // Recebe caractere (bloqueia até receber algo diferente de 0)
        do {
            c = RS232_ADDR;
        } while (c == 0);
        // Ecoa o caractere de volta
        RS232_ADDR = c;
    }
}
