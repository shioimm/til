#include <stdio.h>
#include <stdlib.h>

static void error(const char *s)
{
  perror(s);
  exit(1);
}

int main()
{
  FILE *r, *w;
  char str[1024];
  int c;

  r = fopen("exercises/c/files/lorem_ipsum.txt", "r");
  w = fopen("exercises/c/files/copied_lorem_ipsum.txt", "w");

  while ((c = fgetc(r)) != EOF) {
    if (fputc(c, w) < 0) {
      error("exercises/c/files/read/lorem_ipsum.txt");
    }
  }

  exit(0);
}
