// 例解UNIX/Linuxプログラミング教室 P86

#include <stdio.h>

void map(int p[], int size, int(*func)(int))
{
  int i;

  for(i = 0; i < size; i++) {
    p[i] = func(p[i]);
  }
}

int twice(int x)
{
  return x * 2;
}

int main()
{
  int i;
  int a[5] = {10, 20, 30, 40, 50};
  map(a, 5, twice);

  for(i = 0; i < 5; i++) {
    printf("a[%d] = %d\n", i, a[i]);
  }

  return 0;
}
