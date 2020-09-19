// 参照: 例解UNIX/Linuxプログラミング教室P155

#include <stdio.h>
#include <unistd.h>

int main()
{
  for (int i = 5; i > 0; i--) {
    printf("%d", i);
    fflush(stdout);
    sleep(1);
  }

  printf("go\n");

  return 0;
}
