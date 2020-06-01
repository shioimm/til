/* Two Fer from https://exercism.io */

#include "two_fer.h"
#include <stdio.h>
#include <string.h>

void two_fer(char *buffer, const char *name)
{
  char str[BUFFER_SIZE];

  if (name == NULL) {
    sprintf(str, "%s", "One for you, one for me.");
  } else {
    sprintf(str, "%s%s%s", "One for ", name, ", one for me.");
  }

  strcpy(buffer, str);
}
