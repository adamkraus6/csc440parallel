#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

const int k = 10;

__global__ void sortIntoBins() {
	return;
}

double randDouble(double min, double max)
{
    double range = (max - min); 
    double div = RAND_MAX / range;
    return min + (rand() / div);
}

int main() {
	srand(time(NULL));

	int n = 1 << k;
	int bin_count = 1 << 4; // 16 bins

	// arrays
	double* arr;
	cudaMallocManaged(&arr, n*sizeof(double));
	int* bins;
	cudaMallocManaged(&bins, bin_count*sizeof(int));

	// init array with random values
	for(int i = 0; i < n; i++) {
		// max of 4194304
		arr[i] = randDouble(0, 1<<22);
	}

	// zero bins array
	for(int i = 0; i < bin_count; i++) {
		bins[i] = 0;
	}

	// test print array
	// for(int i = 0; i < n; i++) {
	// 	printf("%.4f\n", arr[i]);
	// }

	int blockSize = 1024;
	int gridSize = (int)ceil(float(n)/blockSize);

	// sort array into bins
	// sortIntoBins<<<blockSize, gridSize>>>();

	int sum = 0;

	// print out number in each bin
	for(int i = 0; i < bin_count; i++) {
		printf("Bin %d: %d\n", i+1, bins[i]);
		sum += bins[i];
	}

	printf("Total bin count: %d (Should be %d)\n", sum, n);
}