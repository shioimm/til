/* Triangle from https://exercism.io */

#ifndef TRIANGLE_H
#define TRIANGLE_H
#include <stdbool.h>

typedef struct {
   double a;
   double b;
   double c;
} triangle_t;

int count_same_values(triangle_t sides);
bool is_all_values_positive(triangle_t sides);
bool is_not_degenerate_triangle(triangle_t sides);
bool is_equilateral(triangle_t sides);
bool is_isosceles(triangle_t sides);
bool is_scalene(triangle_t sides);

#endif
