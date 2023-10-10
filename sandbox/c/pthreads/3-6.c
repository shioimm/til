// Linuxとpthreadsによるマルチスレッドプログラミング入門 P58

#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <stdio.h>

int varA;

void processFunc(int arg)
{
  int n = arg;
  int varB;

  varB = 4 * n;
  printf("processFunc-%d-1: varA=%d varB=%d\n", n, varA, varB);

  varA = 5 * n;
  printf("processFunc-%d-2: varA=%d varB=%d\n", n, varA, varB);

  sleep(2);

  printf("processFunc-%d-3: varA=%d varB=%d\n", n, varA, varB);

  varB = 6 * n;
  printf("processFunc-%d-4: varA=%d varB=%d\n", n, varA, varB);
}

int main()
{
  pid_t process1, process2;
  int varB;

  varA = 1;
  varB = 2;

  printf("main-1:          varA=%d varB=%d\n", varA, varB);

  if ((process1 = fork()) == 0) {
    processFunc(1);
  }

  sleep(1);

  varB = 3;

  printf("main-2:          varA=%d varB=%d\n", varA, varB);

  if ((process2 = fork()) == 0) {
    processFunc(2);
  }

  waitpid(process1, NULL, 0);
  waitpid(process2, NULL, 0);

  printf("main-3:          varA=%d varB=%d\n", varA, varB);

  return 0;
}
