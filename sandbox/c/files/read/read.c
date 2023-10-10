// read 1

#include <stdio.h>  // FILE構造体
#include <string.h> // strerror()
#include <stdlib.h> // exit()

static void error(const char *s)
{
  perror(s);
  exit(1);
}

int main(int argc, char *argv[])
{
  FILE *f
  char str[1024];
  int c;

  f = fopen("exercises/c/files/lorem_ipsum.txt", "r");

  if (f == NULL) {
    error("exercises/c/files/lorem_ipsum.txt");
  }

  while ((c = fgetc(f)) != EOF) {
    if (fputc(c, stdout) < 0) {
      error("exercises/c/files/lorem_ipsum.txt");
    }
  }

  fclose(f);

  exit(0);
}
