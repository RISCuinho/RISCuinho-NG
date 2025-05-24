// Fibonacci iterativo
volatile unsigned int n = 30;
volatile unsigned int a = 0, b = 1, t;
int main() {
    for (volatile unsigned int i = 2; i <= n; ++i) {
        t = a + b;
        a = b;
        b = t;
    }
    while (1);
    return 0;
}
