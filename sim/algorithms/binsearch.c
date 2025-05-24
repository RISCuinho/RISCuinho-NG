// Busca binária
volatile int arr[10] = {1,2,3,4,5,6,7,8,9,10};
volatile int target = 7;
int main() {
    int l = 0, r = 9, m;
    while (l <= r) {
        m = (l + r) / 2;
        if (arr[m] == target) break;
        else if (arr[m] < target) l = m + 1;
        else r = m - 1;
    }
    while (1);
    return 0;
}
