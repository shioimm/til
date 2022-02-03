// Head First C P142

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// $ gcc p142.c -o p142 && ./p142 mermaid mermaid.csv Elvis elvis.csv the_rest.csv
int main(int argc, char *argv[])
{
  char line[80];

  if (argc != 6) {
    fprintf(stderr, "5つの引数を指定してください\n");
    return 1;
  }

  FILE *in    = fopen("spooky.csv", "r");
  FILE *file1 = fopen(argv[2],      "w");
  FILE *file2 = fopen(argv[4],      "w");
  FILE *file3 = fopen(argv[5],      "w");

  while (fscanf(in, "%79[^\n]\n", line) == 1) {
    if (strstr(line, argv[1])) {
      fprintf(file1, "%s\n", line);
    } else if (strstr(line, argv[3])) {
      fprintf(file2, "%s\n", line);
    } else {
      fprintf(file3, "%s\n", line);
    }
  }

  fclose(file1);
  fclose(file2);
  fclose(file3);

  return 0;
}
