// Linuxとpthreadsによるマルチスレッドプログラミング入門 P21

#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

void anotherFunc(int n)
{
  if (n == 1) {
    printf("exit by %d\n", n);
    exit(0);
  }
}

void *threadFunc(void *arg)
{
  int i;

  for (i = 1; i < 3; i++) {
    printf("I'm threadFunc: %d\n", i);
    anotherFunc(i);
    sleep(1);
  }

  return NULL;
}

int main()
{
  pthread_t thread;
  int i;

  if (pthread_create(&thread, NULL, threadFunc, NULL) != 0) {
    printf("Error: Failed to create new thread.\n");
    exit(1);
  }

  for (i = 1; i <= 5; i++) {
    printf("I'm main: %d\n", i);
    sleep(1);
  }

  return 0;
}

