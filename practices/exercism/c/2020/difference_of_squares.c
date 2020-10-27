/* Difference Of Squares from https://exercism.io */

#include "difference_of_squares.h"
#include <math.h>

unsigned int square_of_sum(unsigned int number)
{
  int result = 0;

  for (int i = 1; i <= (int)number; i++) {
    result += i;
  }

  return (int)pow(result, 2);
}

unsigned int sum_of_squares(unsigned int number)
{
  int result = 0;

  for (int i = 1; i <= (int)number; i++) {
    result += (int)pow(i, 2);
  }

  return result;
}

unsigned int difference_of_squares(unsigned int number)
{
  int result = square_of_sum(number) - sum_of_squares(number);

  return result;
}
