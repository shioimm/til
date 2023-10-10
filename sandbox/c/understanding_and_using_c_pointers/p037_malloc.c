// 詳解Cポインタ P37

#include <stdio.h>
#include <stdlib.h>

int main(void)
{
  int *i = malloc(sizeof(int));
  *i = 5;
  printf("%d\n", *i);
  free(i);
}
