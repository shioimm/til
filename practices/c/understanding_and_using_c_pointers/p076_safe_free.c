// 詳説Cポインタ P76
#include <stdlib.h>
#include <stdio.h>

#define safefree(p) safe_free((void**)&(p))

void safe_free(void **pp)
{
  if (pp != NULL && *pp != NULL) {
    free(*pp);
    *pp = NULL;
  }
}

int main(void)
{
  int *p;
  p = malloc(sizeof(int));
  *p = 5;

  printf("Before.. %p\n", p);
  safefree(p);
  printf("After..  %p\n", p);
  safefree(p);

  return 0;
}
