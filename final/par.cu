#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define BIN_COUNT 16

const int k = 29;
const int numPerThread = 16;

__global__ void sortIntoBins(double* arr, int* bins) {
	int temp_bins[BIN_COUNT] = {0};
	int index = blockIdx.x*blockDim.x + threadIdx.x;
	index *= numPerThread;

	for(int i = index; i < index + numPerThread; i++) {
		int bin = (int)arr[i] % BIN_COUNT;
		temp_bins[bin]++;
	}

	for(int i = 0; i < BIN_COUNT; i++) {
		atomicAdd(&bins[i], temp_bins[i]);
	}

}

double randDouble(double min, double max)
{
    double range = (max - min); 
    double div = RAND_MAX / range;
    return min + (rand() / div);
}

int main() {
	srand(time(NULL));

	float time;
	cudaEvent_t start, stop;

	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	int n = 1 << k;

	// arrays
	double* arr;
	cudaMallocManaged(&arr, n*sizeof(double));
	int* bins;
	cudaMallocManaged(&bins, BIN_COUNT*sizeof(int));

	// init array with random values
	for(int i = 0; i < n; i++) {
		// max of 4194304
		arr[i] = randDouble(0, 1<<22);
	}

	// zero bins array
	for(int i = 0; i < BIN_COUNT; i++) {
		bins[i] = 0;
	}

	// play with these numbers
	int blockSize = 1024;
	int gridSize = (int)ceil(float(n/numPerThread)/blockSize);

	// printf("blockSize: %d\ngridSize: %d\n", blockSize, gridSize);

	cudaEventRecord(start);

	// sort array into bins
	sortIntoBins<<<gridSize, blockSize>>>(arr, bins);

	cudaDeviceSynchronize();

	cudaEventRecord(stop);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&time, start, stop);

	printf("Time to sort: %.7f seconds\n", time/1000);

	int sum = 0;

	// print out number in each bin
	for(int i = 0; i < BIN_COUNT; i++) {
		// printf("Bin %d: %d\n", i+1, bins[i]);
		sum += bins[i];
	}

	printf("Total bin count: %d (Should be %d)\n", sum, n);

	cudaFree(arr);
	cudaFree(bins);
}