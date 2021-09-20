// 独習アセンブラ
#include <stdio.h>

extern int sum_asm(void);

extern int array_size = 10;
extern int array[10] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };

int main(void) {
  int sum = sum_asm();
  printf("sum = %d\n", sum);
  return 0;
}

// $ gcc -fno-pic -c -o sum.o sum.c
// $ as -o sum_asm.o sum_asm.s
// $ gcc -o sum sum.o sum_asm.o -no-pie
