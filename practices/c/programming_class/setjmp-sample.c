// 参照: 例解UNIX/Linuxプログラミング教室P436

#include <setjmp.h>
#include <stdio.h>
#include <unistd.h>

static jmp_buf env;

void print_i(int i)
{
  fprintf(stderr, "%d ", i);
  if (i >= 5) {
    putchar('\n');
    longjmp(env, i);
  }
}

int main()
{
  int i;
  setjmp(env);

  for (i = 0;; i++) {
    print_i(i);
    sleep(1);
  }
}
