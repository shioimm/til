#include <stdio.h>
#include <stdlib.h>

void display(int arr[])
{
  int i;

  for (i = 0; i < 3; i++) {
    printf("%i\n", arr[i]);
  }
}
int main()
{
  int *arr;
  arr = malloc(sizeof(int) * 3);

  arr[0] = 0;
  arr[1] = 1;
  arr[2] = 2;

  display(arr); /* 0 -> 1 -> 2 */

  puts("---");

  arr = realloc(arr, sizeof(int) * 4);

  arr[3] = 3;

  display(arr); /* 0 -> 1 -> 2 -> 3 */

  puts("---");

  arr[2] = arr[3];

  arr = realloc(arr, sizeof(int) * 3);

  display(arr); /* 0 -> 1 -> 3 */

  return 0;
}
