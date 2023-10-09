/* Gigasecond from https://exercism.io */

#include "gigasecond.h"
#include <math.h>

time_t gigasecond_after(time_t time)
{
  time_t gigasecond = pow(10, 9);

  return gigasecond + time;
}
