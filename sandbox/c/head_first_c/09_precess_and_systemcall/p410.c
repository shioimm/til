// Head First C P410

#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

int main()
{
  if (execl("/sbin/config", "/sbin/config", NULL) == -1) {
    if (execlp("ipconfig", "ipconfig", NULL) == -1) {
      fprintf(stderr, "ipconfig: %s\n", strerror(errno));
      return 1;
    }
  }

  return 0;
}
