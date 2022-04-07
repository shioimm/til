// 詳説Cポインタ P98

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

char *trim(char *phrase)
{
  char *old = phrase;
  char *new = phrase;

  while (*old == ' ') {
    old++;
  }

  while (*old) {
    *(new++) = *(old++);
  }

  *new = 0;

  return realloc(phrase, strlen(phrase) + 1);
}

int main(void)
{
  char *word = malloc(strlen("  cat") + 1);
  strcpy(word, "  cat");
  printf("%s\n", word);
  printf("%s\n", trim(word));

  return 0;
}
