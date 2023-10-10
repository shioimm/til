// Head First C P414

#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

int main(int argc, char *argv[])
{
  char *myenv[] = { "FOOD=donuts", NULL };

  if (execle("./p414_coffee", "coffee", NULL, myenv) == -1) {
    fprintf(stderr, "Can't order %s\n", strerror(errno));
    return 1;
  }

  return 0;
}
