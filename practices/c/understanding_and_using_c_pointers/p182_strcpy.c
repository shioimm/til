// 詳説Cポインタ P180
#include <stdio.h>
#include <string.h>

void replace(char *buf, char replacement, size_t size)
{
  size_t count = 0;
  while (*buf != NULL && count < size) {
    *buf = replacement;
    buf++;
    count++;
  }
}

int main()
{
  char foo[8];

  strcpy(foo, "1234567");
  printf("%s\n", foo);

  replace(foo, '+', sizeof(foo));
  printf("%s\n", foo);

  return 0;
}
