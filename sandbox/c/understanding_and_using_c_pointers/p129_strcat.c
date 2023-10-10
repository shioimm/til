// 詳説Cポインタ P129

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(void)
{
  char *foo = "FOO";
  char *bar = "BAR";

  char *buf = malloc(strlen(foo) + strlen(bar) + 1);

  strcpy(buf, foo);
  strcat(buf, bar);

  printf("%s\n", foo);
  printf("%s\n", bar);
  printf("%s\n", buf);

  return 0;
}
