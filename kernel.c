#include "params.h"
#include <stdint.h>

void kernel(uint64_t input_ct[M], uint64_t ksk3d[M][N][K],
            uint64_t output_ct[K]) {
  for (int i = 0; i < M; i++) {
    uint64_t dec_state = input_ct[i];
    for (int j = 0; j < N; j++) {
      for (int k = 0; k < K; k++) {
        output_ct[k] -= ksk3d[i][j][k] * dec_state;
      }
    }
  }
}
