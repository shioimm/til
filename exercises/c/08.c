#include <stdio.h>

void display(char arr[][10])
{
  int i;

  for (i = 0; i < 3; i++) {
    printf("%s\n", arr[i]);
  }
}
int main()
{
  char arr[][10] = { "Blue", "Yellow", "Red" };
  display(arr);

  return 0;
}
