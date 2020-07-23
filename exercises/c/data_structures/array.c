/* 配列 */

#include <stdio.h>

void display(int data[], int size)
{
  int i;

  for (i = 0; i < size; i++) {
    printf("%i\n", data[i]);
  }
}
int main()
{
  int data[10];

  data[0] = 0;
  data[1] = 1;
  data[2] = 2;
  display(data, 3); /* 0 -> 1 -> 2 */

  puts("----");

  /* 挿入 */
  data[3] = data[2];
  data[2] = 3;
  display(data, 4); /* 0 -> 1 -> 3 -> 2 */

  puts("----");

  /* 削除 */
  data[2] = data[3];
  data[3] = data[4];
  display(data, 4); /* 0 -> 1 -> 2 -> 0 */

  return 0;
}
