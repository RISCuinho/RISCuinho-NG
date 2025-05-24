// Multiplicação de matrizes 3x3
volatile int A[3][3] = {{1,2,3},{4,5,6},{7,8,9}};
volatile int B[3][3] = {{9,8,7},{6,5,4},{3,2,1}};
volatile int C[3][3];
int main() {
    for (volatile int i = 0; i < 3; ++i)
        for (volatile int j = 0; j < 3; ++j) {
            C[i][j] = 0;
            for (volatile int k = 0; k < 3; ++k)
                C[i][j] += A[i][k] * B[k][j];
        }
    while (1);
    return 0;
}
