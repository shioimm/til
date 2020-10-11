// 参照: 例解UNIX/Linuxプログラミング教室P441

#include <setjmp.h>
#include <stdio.h>
#include <stdlib.h>
#include "mysub.h"

static jmp_buf env;

void do_show_item(int num)
{
  if (num > 10) {
    fprintf(stderr, "no such item: %d\n", num);
    longjmp(env, 1);
  }
  printf("item: %d\n", num);
}

void do_show()
{
  int item_no = getint("item number? ");
  do_show_item(item_no);
}

void do_input()
{
  printf("input done\n");
}

void do_end()
{
  exit(0);
}

int main()
{
  int command;

  if (setjmp(env) != 0) {
    fprintf(stderr, "error recovered\n");
  }

  while(1) {
    command = getint("command (0 = show, 1 = input, 2 = end)? ");

    switch (command) {
      case 0: do_show();  break;
      case 1: do_input(); break;
      case 2: do_end();   break;
      default:
        fprintf(stderr, "unknown command\n");
        break;
    }
  }
}
