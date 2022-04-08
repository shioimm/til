// 詳説Cポインタ P138

#include <stdio.h>
#include <string.h>

char *lit(int code)
{
  static char foo[] = "FOO";
  static char bar[] = "BAR";

  switch(code) {
    case 100:
      return foo;
    case 200:
      return bar;
  }
}

int main(void)
{
  printf("%s\n", lit(100));

  return 0;
}
