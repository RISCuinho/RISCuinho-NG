// FFT simplificada (apenas para simulação de laços e aritmética)
volatile int real[8] = {1,2,3,4,5,6,7,8};
volatile int imag[8] = {0,0,0,0,0,0,0,0};
int main() {
    for (volatile int i = 0; i < 8; ++i)
        for (volatile int j = 0; j < 8; ++j) {
            int t = real[i] * real[j] - imag[i] * imag[j];
            int u = real[i] * imag[j] + imag[i] * real[j];
            real[i] = t;
            imag[i] = u;
        }
    while (1);
    return 0;
}
