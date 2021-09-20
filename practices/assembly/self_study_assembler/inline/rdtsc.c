// 独習アセンブラ
#include <stdio.h>

extern unsigned int rdtsc(void);

int main(void) {
  unsigned int counter = rdtsc();
  printf("%u\n", counter);
  return 0;
}

// $ gcc -fno-pic -c -o rdtsc.o rdtsc.c
// $ as -o rdtsc_ascm.o rdtsc_ascm.s
// $ gcc -o rdtsc rdtsc.o rdtsc_ascm.o -no-pie
