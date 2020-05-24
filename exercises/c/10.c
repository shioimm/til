#include <stdio.h>
#include <string.h>  // strcpy
#define SIZE 5

void display(char arr[SIZE][10])
{
  int i;

  for (i = 0; i < SIZE; i++) {
    printf("%s\n", arr[i]);
  }
}

int main()
{
  char arr[SIZE][10];

  char blue[5]   = "Blue";
  char yellow[7] = "Yellow";
  char red[4]    = "Red";

  strcpy(arr[0], blue);
  strcpy(arr[1], yellow);
  strcpy(arr[2], red);

  display(arr); /* Blue -> Yellow -> Red */

  puts("---");

  char green[6] = "Green";

  strcpy(arr[3], arr[2]);
  strcpy(arr[2], green);

  display(arr); /* Blue -> Yellow -> Green -> Red */

  puts("---");

  strcpy(arr[2], arr[3]);
  strcpy(arr[3], arr[4]);

  display(arr); /* Blue -> Yellow -> Red */

  return 0;
}
