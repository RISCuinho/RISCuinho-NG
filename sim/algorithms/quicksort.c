// Quick Sort
void quicksort(volatile int *arr, int left, int right) {
    int i = left, j = right;
    int pivot = arr[(left + right) / 2];
    while (i <= j) {
        while (arr[i] < pivot) i++;
        while (arr[j] > pivot) j--;
        if (i <= j) {
            int t = arr[i]; arr[i] = arr[j]; arr[j] = t;
            i++; j--;
        }
    }
    if (left < j) quicksort(arr, left, j);
    if (i < right) quicksort(arr, i, right);
}
volatile int arr[10] = {10,9,8,7,6,5,4,3,2,1};
int main() {
    quicksort(arr, 0, 9);
    while (1);
    return 0;
}
