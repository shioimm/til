// Head First C P167

#include <stdio.h>
#include <limits.h> // int, char
#include <float.h>  // float, double

int main()
{
  printf("INT_MAX:       %i\n",    INT_MAX);
  printf("INT_MIN:       %i\n",    INT_MIN);
  printf("sizeof(int):   %zu\n",   sizeof(int));
  printf("FLT_MAX:       %f\n",    FLT_MAX);
  printf("FLT_MAX:       %.50f\n", FLT_MAX);
  printf("sizeof(float): %zu\n",   sizeof(float));

  return 0;
}

// INT_MAX:       2147483647
// INT_MIN:       -2147483648
// sizeof(int):   4
// FLT_MAX:       340282346638528859811704183484516925440.000000
// FLT_MAX:       340282346638528859811704183484516925440.00000000000000000000000000000000000000000000000000
// sizeof(float): 4
