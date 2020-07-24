/*
 * 引用: Head First C
 * 第10章 プロセスとシステムコール 4
*/

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

int main(int argc, char *argv[])
{

  char *my_env[] = { "FOOD=coffee", NULL };

  if (execl("~/til/c/head_first/10_precess_and_systemcall/04_coffee/coffee", "~/til/c/head_first/10_precess_and_systemcall/04_coffee/coffee", "donuts", NULL, my_env) == -1) {
    fprintf(stderr, "注文を作成できません: %s\n", strerror(errno));
    return 1;
  }

  return 0;
}
