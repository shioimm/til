// 詳説Cポインタ P121

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void)
{
  char str1[4];
  strcpy(str1, "FOO");
  printf("%s\n", str1);

  char *str2;
  str2 = malloc(strlen("BAR") + 1);
  strcpy(str2, "BAR");
  printf("%s\n", str2);

  char *str3 = "BUZ";
  printf("%s\n", str3);

  return 0;
}
