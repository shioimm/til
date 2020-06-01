/* Resistor Color Duo from https://exercism.io */

#include "resistor_color_duo.h"

int color_code(resistor_band_t colors[])
{
  return (colors[0] * 10) + colors[1];
}
