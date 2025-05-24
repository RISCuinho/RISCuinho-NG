// Fatorial grande
volatile unsigned int res = 1;
volatile unsigned int n = 12;
int main() {
    for (volatile unsigned int i = 2; i <= n; ++i) res *= i;
    while (1);
    return 0;
}
