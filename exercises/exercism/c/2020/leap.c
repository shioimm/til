/* Leap from https://exercism.io/ */

#include "leap.h"

bool is_leap_year(int year)
{
  if (year % 400 == 0) {
    return true;
  }

  if (year % 100 == 0) {
    return false;
  }

  return year % 4 == 0;
}
