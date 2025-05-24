// Teste equivalente em C para referência
volatile int a = 12345, b = 54321;
volatile int r_mul, r_mulh, r_mulhu, r_mulhsu, r_div, r_divu, r_rem, r_remu;
int main() {
    r_mul    = a * b;
    r_mulh   = ((long long)a * (long long)b) >> 32;
    r_mulhu  = ((unsigned long long)(unsigned int)a * (unsigned long long)(unsigned int)b) >> 32;
    r_mulhsu = ((long long)a * (unsigned long long)(unsigned int)b) >> 32;
    r_div    = b / a;
    r_divu   = ((unsigned int)b) / ((unsigned int)a);
    r_rem    = b % a;
    r_remu   = ((unsigned int)b) % ((unsigned int)a);
    while (1);
    return 0;
}
