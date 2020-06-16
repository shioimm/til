/* Acronym from https://exercism.io */

#include "acronym.h"
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <ctype.h>

bool is_blank(const char *phrase)
{
  return phrase == NULL || !strncmp(phrase, "", 1);
}

char *abbreviate(const char *phrase)
{
  if (is_blank(phrase)) {
    return NULL;
  }

  size_t size = strlen(phrase);
  char str[size];
  char *token;
  char *acronym = malloc(sizeof(phrase) * size);

  strcpy(str, phrase);
  token = strtok(str, " -");

  for (int i = 0; token != NULL; i++) {
    acronym[i] = toupper(token[0]);
    token = strtok(NULL, " -");
  }

  return acronym;
}
