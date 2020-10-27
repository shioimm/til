/* Armstrong Numbers from https://exercism.io */

#include "armstrong_numbers.h"
#include <math.h>

int count_digit(int base)
{
  int digit = 0;

  while (base != 0) {
    base = base / 10;
    digit++;
  }

  return digit;
}

int is_armstrong_number(int candidate)
{
  int digit = count_digit(candidate);

  if (digit == 0 || digit == 1) {
    return 1;
  }

  int target_digit = pow(10, (digit - 1));
  int rem = candidate;
  int result = 0;

  while (rem != 0) {
    result = result + (int)pow((rem / target_digit), digit);
    rem = candidate % target_digit;
    target_digit = target_digit / 10;
  }

  return (result == candidate);
}
