// Bubble Sort
volatile int arr[10] = {9,8,7,6,5,4,3,2,1,0};
int main() {
    for (volatile int i = 0; i < 10; i++)
        for (volatile int j = 0; j < 9-i; j++)
            if (arr[j] > arr[j+1]) {
                int t = arr[j]; arr[j] = arr[j+1]; arr[j+1] = t;
            }
    while (1);
    return 0;
}
