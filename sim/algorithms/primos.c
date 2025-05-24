// Crivo de Eratóstenes
volatile char is_prime[100];
int main() {
    for (volatile int i = 0; i < 100; ++i) is_prime[i] = 1;
    for (volatile int i = 2; i < 100; ++i)
        if (is_prime[i])
            for (volatile int j = i*i; j < 100; j += i)
                is_prime[j] = 0;
    while (1);
    return 0;
}
