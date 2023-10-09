/* Binary from https://exercism.io */

#include "binary.h"
#include <string.h>
#include <math.h>

int convert(const char *input)
{
  int len = strlen(input);
  int inc = 0;
  int dec = len - 1;
  char reversed[len];

  while (dec >= 0) {
    reversed[dec] = input[inc];
    inc++;
    dec--;
  }

  reversed[len] = '\0';

  int result = 0;

  for (inc = 0; inc < len; inc++) {
    int num;

    switch (reversed[inc]) {
      case '0':
        num = 0;
        break;
      case '1':
        num = 1;
        break;
      default:
        return -1;
    }

    result += (num * (int)(pow(2, inc)));
  }

  return result;
}
