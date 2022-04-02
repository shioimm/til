// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P88
#include <stdio.h>

int foo;

int main(void)
{
  char buf[256];

  printf("&foo.. %p\n", (void*)&foo);

  printf("Input initial value.\n");
  fgets(buf, sizeof(buf), stdin);
  sscanf(buf, "%d", &foo);

  for (;;) {
    printf("foo..  %d\n", foo);
    getchar();
    foo++;
  }

  return 0;
}
