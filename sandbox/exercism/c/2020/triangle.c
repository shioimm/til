/* Triangle from https://exercism.io */

#include "triangle.h"

int count_same_values(triangle_t sides)
{
  int count = 0;

  if (sides.a == sides.b) {
    count++;
  }

  if (sides.a == sides.c) {
    count++;
  }

  if (sides.b == sides.c) {
    count++;
  }

  return count;
}

bool is_all_values_positive(triangle_t sides)
{
  return sides.a > 0 && sides.b > 0 && sides.c > 0;
}

bool is_not_degenerate_triangle(triangle_t sides)
{
  return (sides.b + sides.c >= sides.a)
         && (sides.a + sides.c >= sides.b)
         && (sides.a + sides.b >= sides.c);
}

bool is_equilateral(triangle_t sides)
{
  bool is_valid_values = is_all_values_positive(sides);
  int same_values = count_same_values(sides);

  return is_valid_values && same_values == 3;
}

bool is_isosceles(triangle_t sides)
{
  bool is_valid_values = is_all_values_positive(sides) && is_not_degenerate_triangle(sides);
  int same_values = count_same_values(sides);

  return is_valid_values && same_values >= 1;
}

bool is_scalene(triangle_t sides)
{
  bool is_valid_values = is_all_values_positive(sides) && is_not_degenerate_triangle(sides);
  int same_values = count_same_values(sides);

  return is_valid_values && same_values == 0;
}
