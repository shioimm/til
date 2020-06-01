/* Dart from https://exercism.io */

#include "darts.h"
#include <math.h>

int score(coordinate_t landing_position)
{
  float squared_x = pow(landing_position.x, 2.0);
  float squared_y = pow(landing_position.y, 2.0);
  float point = sqrt(squared_x + squared_y);

  if (point <= 1) {
    return 10;
  } else if (point <= 5) {
    return 5;
  } else if (point <= 10) {
    return 1;
  }

  return 0;
}
