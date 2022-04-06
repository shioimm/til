// 詳説Cポインタ P70

#include <stdio.h>
#include <stdlib.h>

int *allocate_array(int size, int value)
{
  int *arr = malloc(sizeof(int) * size);

  for (int i = 0; i < size; i++) {
    arr[i] = value;
  }

  return arr;
}

int main(void)
{
  int *vector = allocate_array(5, 45);

  for (int i = 1; i < 5; i++) {
    printf("%d\n", vector[i]);
  }

  free(vector);

  return 0;
}
