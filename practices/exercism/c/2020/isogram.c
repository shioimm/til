/* Isogram from https://exercism.io */

#include "isogram.h"
#include <string.h>
#include <ctype.h>

#define NOT_UNIQUE_NUM 2

bool is_isogram(const char phrase[])
{
  if (phrase == NULL) {
    return false;
  }

  int size_of_phrase = (int)strlen(phrase);
  int max_size_of_duplication = 0;
  int buf;

  for(int i = 0; i < size_of_phrase; i++) {
    if (phrase[i] == '-' || phrase[i] == ' ') {
      continue;
    }
    buf = 0;

    for(int j = 0; j < size_of_phrase; j++) {
      if (tolower(phrase[i]) == tolower(phrase[j])) {
        buf++;
        if (buf >= max_size_of_duplication) {
          max_size_of_duplication = buf;
        }
      }
    }
  }

  return NOT_UNIQUE_NUM > max_size_of_duplication;
}
