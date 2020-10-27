#include <stdio.h>
#include <stdlib.h>

static void error(const char *msg) {
  perror(msg);
  exit(1);
}

int main(int argc, char *argv[])
{
  if (argc < 2) {
    fprintf(stderr, "%s: File name not given\n", argv[0]);
    exit(1);
  }

  FILE *f;
  int c;

  f = fopen(argv[1], "r");

  if (!f) error(argv[1]);

  while ((c = fgetc(f)) != EOF) {
    if (fputc(c, stdout) < 0) error(argv[1]);
  }

  fclose(f);
  exit(0);
}
