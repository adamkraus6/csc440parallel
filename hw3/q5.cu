// Adam Kraus
// CSC 440
// Homework 3 due 3/25/2024
// Question 5

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

const int k = 20;

__device__ void Merge(unsigned long long* a, unsigned long long* temp, unsigned long long left, unsigned long long middle, unsigned long long right) {
    unsigned long long i = left;
    unsigned long long j = middle;
    unsigned long long k = left;

    while (i < middle && j < right) 
    {
        if (a[i] <= a[j])
            temp[k++] = a[i++];
        else
            temp[k++] = a[j++];
    }

    while (i < middle)
        temp[k++] = a[i++];
    while (j < right)
        temp[k++] = a[j++];

    for (unsigned long long x = left; x < right; x++)
        a[x] = temp[x];
}

__global__ void sortMerge(unsigned long long *a, unsigned long long *temp, unsigned long long n, unsigned long long w) {
	unsigned long long i = blockDim.x * blockIdx.x + threadIdx.x;
    unsigned long long left = i * w;
    unsigned long long mid = left + w / 2;
    unsigned long long right = left + w;

    if (left < n && mid < n) 
    {
        Merge(a, temp, left, mid, right);
    }
}

int main() {
	srand(time(NULL));

	float time;
	cudaEvent_t start, stop;

	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	// n = 2^k
	unsigned long long n = 1 << k;

	// allocate a[n]
	unsigned long long *d_a;
	cudaMallocManaged(&d_a, n*sizeof(unsigned long long));
	unsigned long long *temp;
	cudaMallocManaged(&temp, n*sizeof(unsigned long long));

	// initialize a w/ 0 to n-1
	for(unsigned long long i = 0; i < n; i++) {
		d_a[i] = i;
	}

	// shuffle a
	for(unsigned long long i = 0; i < n-1; i++) {
		unsigned long long j = rand() % (n - i) + i;

		unsigned long long temp_val = d_a[i];
		d_a[i] = d_a[j];
		d_a[j] = temp_val;
	}

	// for(unsigned long long i = 0; i < 100; i++) {
	// 	printf("%llu\n", d_a[i]);
	// }

	unsigned long long blockSize = 1024;
	unsigned long long gridSize = (unsigned long long)ceil(float(n)/(blockSize));

	cudaEventRecord(start);

	// sort a on device (merge)
	for(unsigned long long w = 1; w < n; w *= 2) {
		sortMerge<<<blockSize, gridSize>>>(d_a, temp, n, w*2);
	}

	// wait for GPU
	cudaDeviceSynchronize();

	cudaEventRecord(stop);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&time, start, stop);

	printf("Time to sort:  %3.1f ms \n", time);

	// check sorted
	bool sorted = true;
	
	for(unsigned long long i = 0; i < n-1; i++) {
		if(d_a[i] > d_a[i+1]) {
			sorted = false;
			printf("%llu\n", i);
			break;
		}
	}

	cudaFree(d_a);
	cudaFree(temp);

	printf(sorted ? "Sorted\n" : "Not sorted\n");
}