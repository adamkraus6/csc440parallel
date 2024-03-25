// Adam Kraus
// CSC 440
// Homework 3 due 3/25/2024
// Question 4

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

const int k = 20;

__global__ void sortOddEven(unsigned long long *a, unsigned long long n, unsigned long long phase) {
	unsigned long long i = blockIdx.x * blockDim.x + threadIdx.x;
	// odd threads work on odd phase, even on even
	if(i+1 < n & (i%2 == phase%2)) {
		if(a[i] > a[i+1]) {
			unsigned long long temp = a[i];
			a[i] = a[i+1];
			a[i+1] = temp;
		}
	}
}

int main() {
	float time;
	cudaEvent_t start, stop;

	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	// n = 2^k
	unsigned long long n = 1 << k;

	// allocate a[n]
	unsigned long long *d_a;
	cudaMallocManaged(&d_a, n*sizeof(unsigned long long));

	// initialize a w/ 0 to n-1
	for(unsigned long long i = 0; i < n; i++) {
		d_a[i] = i;
	}

	// shuffle a
	for(unsigned long long i = 0; i < n-1; i++) {
		unsigned long long j = rand() % (n - i) + i;

		unsigned long long temp = d_a[i];
		d_a[i] = d_a[j];
		d_a[j] = temp;
	}

	unsigned long long blockSize = 4096;
	unsigned long long gridSize = (unsigned long long)ceil(float(n)/(blockSize));

	cudaEventRecord(start);

	// sort a on device (odd-even)
	for(unsigned long long phase = 0; phase < n; phase++) {
		sortOddEven<<<blockSize, gridSize>>>(d_a, n, phase);
	}

	// wait for GPU
	cudaDeviceSynchronize();

	cudaEventRecord(stop);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&time, start, stop);

	printf("Time to sort: %3.1f ms \n", time);

	// check sorted
	bool sorted = true;
	
	for(unsigned long long i = 0; i < n-1; i++) {
		if(d_a[i] > d_a[i+1]) {
			sorted = false;
		}
	}

	cudaFree(d_a);

	printf(sorted ? "Sorted\n" : "Not sorted\n");
}