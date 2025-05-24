// Multiplicação de grandes inteiros (simples)
volatile unsigned int a = 123456, b = 654321;
volatile unsigned long long res = 0;
int main() {
    for (volatile int i = 0; i < 32; ++i)
        if ((b >> i) & 1) res += ((unsigned long long)a << i);
    while (1);
    return 0;
}
