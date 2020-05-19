/* 配列 */

#include <stdio.h>
#include <stdlib.h>

void display(int data[], int size)
{
  int i;

  for (i = 0; i < size; i++) {
    printf("%i\n", data[i]);
  }
}
int main()
{
  int *data;

  data = malloc(sizeof(int) * 3);
  data[0] = 0;
  data[1] = 1;
  data[2] = 2;
  display(data, 3); /* 0 -> 1 -> 2 */

  puts("----");

  /* 挿入 */
  data = realloc(data,sizeof(int) * 1);
  data[3] = data[2];
  data[2] = 3;
  display(data, 4); /* 0 -> 1 -> 3 -> 2 */

  return 0;
}
