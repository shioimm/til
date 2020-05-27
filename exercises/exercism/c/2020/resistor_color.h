/* Resistor Color from https://exercism.io */

#ifndef RESISTOR_COLOR_H
#define RESISTOR_COLOR_H

typedef enum resistor_band_t {
  BLACK,
  BROWN,
  RED,
  ORANGE,
  YELLOW,
  GREEN,
  BLUE,
  VIOLET,
  GREY,
  WHITE,
} resistor_band_t;

int color_code(resistor_band_t color);
resistor_band_t *colors();

#endif
