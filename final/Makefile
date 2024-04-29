all: clean parallel sequential
clean:
	rm parallel sequential -f
parallel:
	nvcc -o parallel par.cu
sequential:
	gcc -o sequential seq.c