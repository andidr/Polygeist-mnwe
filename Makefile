CFLAGS = -I.

kernel.cgeist.o: kernel.c
	cgeist -c $< --function=kernel -I. --memref-fullrank -o $@ -O3

kernel.cgeist.mlir: kernel.c
	cgeist $< --function=kernel -S -I. --memref-fullrank --raise-scf-to-affine -o $@

kernel.polymer.mlir: kernel.cgeist.mlir
	polymer-opt $< -reg2mem -extract-scop-stmt -pluto-opt -o $@ --allow-unregistered-dialect >/dev/null 2>&1

kernel.nopolymer.mlir: kernel.cgeist.mlir
	cp $< $@

%.low.mlir: %.mlir
	mlir-opt \
		-lower-affine \
		-convert-scf-to-cf \
		-cse \
		-canonicalize \
		-convert-func-to-llvm="use-bare-ptr-memref-call-conv" \
		--finalize-memref-to-llvm \
		-canonicalize \
		-o $@ $<

kernel.polymer.ll: kernel.polymer.low.mlir
	mlir-translate -mlir-to-llvmir -o $@ $^

kernel.polymer.S: kernel.polymer.ll
	llc -opaque-pointers -o $@ $^

kernel.polymer.o: kernel.polymer.S
	as -o $@ $^

%.O0.o: %.c
	gcc -O0 -g $(CFLAGS) -c $< -o $@

%.O3.o: %.c
	gcc -O3 $(CFLAGS) -c $< -o $@

mnwe.debug: main.c kernel.O0.o
	gcc -O0 -g $(CFLAGS) $^ -o $@

mnwe.O3: main.c kernel.O3.o
	gcc -O3 $(CFLAGS) $^ -o $@

mnwe.polymer: main.c kernel.polymer.o
	gcc -O3 $(CFLAGS) $^ -o $@

mnwe.cgeist: main.c kernel.cgeist.o
	gcc -O3 $(CFLAGS) -o $@ $^

clean:
	rm -f *.o mnwe.debug mnwe.O3 mnwe.pluto *.mlir *.ll *.S mnwe.cgeist mnwe.O3 mnwe.debug mnwe.polymer *~
