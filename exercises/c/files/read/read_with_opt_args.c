#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>

#define DEFAULT_PATH "exercises/c/files/read/lorem_ipsum.txt"

static void error(const char *message) {
  perror(message);
  exit(1);
}

static struct option longopts[] = {
  { "src",  required_argument, NULL, 's' },
  { "help", no_argument,       NULL, 'h' },
  { 0, 0, 0, 0},
};

int main(int argc, char *argv[])
{
  int opt;
  FILE *f;
  int c;
  char path[1024];

  while ((opt = getopt_long(argc, argv, "s:h", longopts, NULL)) != -1) {
    switch (opt) {
      case 's':
        strcpy(path, optarg);
        break;
      case 'h':
        fprintf(stdout, "Usage: %s [-s FILE]\n", argv[0]);
        exit(0);
      case '?':
        fprintf(stderr, "Usage: %s [-s FILE]\n", argv[0]);
        exit(1);
    }
  }

  if (argc < 2) {
    strcpy(path, DEFAULT_PATH);
  }

  f = fopen(path, "r");

  while ((c = fgetc(f)) != EOF) {
    if (fputc(c, stdout) < 0) {
      error(path);
    }
  }

  exit(0);
}
