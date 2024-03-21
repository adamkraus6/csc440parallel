// Adam Kraus
// CSC 440
// Homework 3 due 3/25/2024
// Question 3

__global__ void transpose(matrix) {
	// i row, j col

	int i = threadIdx.x / blockDim.x + blockDim.x * blockIdx.x
	int j = threadIdx.y % blockDim.y + blockDim.y * blockIdx.y

	// on diagonal or above
	if(j >= i) return;

	swap(matrix[i][j], matrix[j][i]);
}

