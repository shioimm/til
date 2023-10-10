/* Resistor Color from https://exercism.io */

#include <stdlib.h>
#include "resistor_color.h"

int color_code(resistor_band_t color)
{
  return color;
}

resistor_band_t *colors()
{
  resistor_band_t *codes = malloc(sizeof(resistor_band_t) * WHITE);

  for (resistor_band_t i = BLACK; i <= WHITE; i++) {
    codes[i] = i;
  }

  return codes;
}
