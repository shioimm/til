// Head First C P57

#include <stdio.h>

int main()
{
  int contesttants[] = { 1, 2, 3 };
  int *choice = contesttants; // *choice = contesttants[0]

  printf("contesttants: %p\n", contesttants); // contesttants[0]のメモリアドレス
  printf("&contesttants: %p\n", &contesttants); // contesttants[0]のメモリアドレス
  printf("contesttants[0]: %i\n", contesttants[0]); // 1
  printf("&contesttants[0]: %p\n", &contesttants[0]); // contesttants[0]のメモリアドレス
  printf("contesttants[0]: %i\n", *contesttants); // 1

  puts("----");

  printf("choice: %p\n", choice); // contesttants[0]と同じメモリアドレス
  printf("&choice: %p\n", &choice); // choiceのメモリアドレス
  printf("*choice: %i\n", *choice); // 1

  puts("----");

  contesttants[0] = 2; // { 2, 2, 3 }
  contesttants[1] = contesttants[2]; // { 2, 3, 3 }
  contesttants[2] = *choice; // { 2, 3, 2 }
  printf("出席番号%i\n", contesttants[2]); // 2

  return 0;
}
