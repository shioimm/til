#include <stdio.h>
#include <string.h>

int main(void)
{
  int *p;
  int i;
  p = &i;
  i = 1;
  printf("%d\n", *p);

  char str[10];
  strcpy(str, "abc");
  printf("%s\n", str);

  return 0;
}
