// 詳説Cポインタ P73

#include <stdio.h>
#include <stdlib.h>

int *allocate_array(int *arr, int size, int value)
{
  if (arr != NULL) {
    for (int i = 0; i < size; i++) {
      arr[i] = value;
    }
  }

  return arr;
}

int main(void)
{
  int *vector = malloc(sizeof(int) * 5);
   allocate_array(vector, 5, 45);

  for (int i = 1; i < 5; i++) {
    printf("%d\n", vector[i]);
  }

  free(vector);

  return 0;
}
