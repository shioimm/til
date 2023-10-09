/* Hamming from https://exercism.io */

#include "hamming.h"
#include <string.h>

int compute(const char *lhs, const char *rhs)
{
  int is_null = (lhs == NULL) || (rhs == NULL);

  if (is_null || (int)strlen(lhs) != (int)strlen(rhs)) {
    return -1;
  }

  int count = 0;

  for (int i = 0; i < (int)strlen(lhs); i++) {
    if (lhs[i] != rhs[i]) {
      count += 1;
    }
  }
  return count;
}
