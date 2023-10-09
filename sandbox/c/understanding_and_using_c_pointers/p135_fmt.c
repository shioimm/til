// 詳説Cポインタ P135

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *fmt(char *buf, size_t size, const char *name, size_t quantity, size_t weight)
{
  snprintf(buf, size, "Item: %s, Quantity: %zu, Weight: %zu", name, quantity, weight);

  return buf;
}

int main(void)
{
  char buf1[100];
  printf("%s\n", fmt(buf1, sizeof(buf1), "Axle", 25, 45));

  char *buf2 = malloc(sizeof(char) * 100);
  printf("%s\n", fmt(buf2, sizeof(char) * 100, "Axle", 25, 45));

  free(buf2);

  return 0;
}
