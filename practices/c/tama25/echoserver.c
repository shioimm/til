#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main ()
{
  char msg[1024];

  for (;;) {
    fgets(msg, sizeof(msg), stdin);
    printf("%s", msg);
  }

  return 0;
}
