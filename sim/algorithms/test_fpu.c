// Teste de FPU em C (referência)
volatile float a = 10.0f, b = 5.0f;
volatile float r_add, r_sub, r_mul, r_div;
int main() {
    r_add = a + b;
    r_sub = a - b;
    r_mul = a * b;
    r_div = a / b;
    while (1);
    return 0;
}
