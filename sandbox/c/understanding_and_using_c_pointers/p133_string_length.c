// 詳説Cポインタ P133

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

size_t string_length(const char *str)
{
  size_t len = 0;
  while (*(str++)) {
    len++;
  }

  return len;
}

int main(void)
{
  char str1[] = "string";
  char *str2 = malloc(strlen("string") + 1);
  strcpy(str2, "string");

  printf("%d\n", (int)string_length(str1));
  printf("%d\n", (int)string_length(&str1));
  printf("%d\n", (int)string_length(&str1[0]));
  printf("%d\n", (int)string_length(str2));

  free(str2);

  return 0;
}
