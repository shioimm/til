// 詳説Cポインタ P74

#include <stdio.h>
#include <stdlib.h>

void allocate_array(int **arr, int size, int value)
{
  *arr = malloc(sizeof(int) * size);

  if (*arr != NULL) {
    for (int i = 0; i < size; i++) {
      *(*arr + i) = value;
    }
  }
}

int main(void)
{
   int *vector = NULL;
   allocate_array(&vector, 5, 45);

  for (int i = 1; i < 5; i++) {
    printf("%d\n", vector[i]);
  }

  free(vector);

  return 0;
}
