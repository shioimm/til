// 参照: 例解UNIX/Linuxプログラミング教室P180

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main()
{
  int age;
  printf("Welcome!\n");
  printf("your age: ");
  fprintf(stderr, "Input ");
  scanf("%d\n", &age);
  printf("Your age is %d", age);
  fprintf(stderr, "Thank you! ");
  printf("\nBye!");
  sleep(3);

  exit(0);
}
