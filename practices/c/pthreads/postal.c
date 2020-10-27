// Linuxとpthreadsによるマルチスレッドプログラミング入門 P228

#include "postalnumber.h"
#include <stdio.h>
#include <string.h>

#define SEARCH_SIZE 100

static void getString(char *buf, size_t buflen)
{
  int ch;
  buflen--;

  while ((ch = getchar()) != EOF) {
    if (ch == '\r') {
      continue;
    }
    if (ch == '\n') {
      break;
    }
    if (buflen > 0) {
      *(buf++) = ch;
      buflen--;
    }
  }
  *buf = '\0';
}

int main(void)
{
  PostalNumberLoadDB();
  printf("Search ? ");
  fflush(stdout);
  char buf[128];
  getString(buf, sizeof(buf));
  printf("Search for '%s': \n", buf);
  PostalNumber res[SEARCH_SIZE];
  size_t n = PostalNumberSearch(buf, res, SEARCH_SIZE);

  for (size_t i = 0; i < n; i++) {
    printf(" %s %s %s %s\n", res[i].code, res[i].pref, res[i].city, res[i].town);
  }

  return 0;
}
