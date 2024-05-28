#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

#include "params.h"

void kernel(uint64_t input_ct[M], uint64_t ksk3d[M][N][K],
            uint64_t output_ct[K]);

uint64_t input_ct[M] = {1};
uint64_t ksk3d[M][N][K] = {1};
uint64_t output_ct[K] = {9};

int main(int argc, char **argv) {
  kernel(input_ct, ksk3d, output_ct);

  uint64_t res = 0;

  for (int i = 0; i < K; i++)
    res += output_ct[i];

  printf("res: %" PRIu64 "\n", res);

  return 0;
}
