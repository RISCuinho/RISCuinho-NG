// Algoritmo de Dijkstra (grafo fixo)
#define N 5
volatile int dist[N];
volatile int visited[N];
volatile int graph[N][N] = {
    {0, 6, 0, 1, 0},
    {6, 0, 5, 2, 2},
    {0, 5, 0, 0, 5},
    {1, 2, 0, 0, 1},
    {0, 2, 5, 1, 0}
};
int main() {
    for (volatile int i = 0; i < N; ++i) { dist[i] = 1000; visited[i] = 0; }
    dist[0] = 0;
    for (volatile int count = 0; count < N-1; ++count) {
        int u = -1, min = 1001;
        for (volatile int i = 0; i < N; ++i)
            if (!visited[i] && dist[i] < min) { min = dist[i]; u = i; }
        visited[u] = 1;
        for (volatile int v = 0; v < N; ++v)
            if (!visited[v] && graph[u][v] && dist[u] + graph[u][v] < dist[v])
                dist[v] = dist[u] + graph[u][v];
    }
    while (1);
    return 0;
}
