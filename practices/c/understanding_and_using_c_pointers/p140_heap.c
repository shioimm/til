// 詳説Cポインタ P138

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *blanks(int n)
{
  char *spaces = malloc(n + 1);
  int i;

  for (i = 0; i < n; i++) {
    spaces[i] = ' ';
  }

  spaces[n] = '\0';
  return spaces;
}

int main(void)
{
  char *tmp = blanks(10);
  printf("[%s]\n", tmp);
  free(tmp);

  return 0;
}
