#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

void *inner_func(void *arg)
{
  while (1) {
    puts("inner");
  }

  return NULL;
}

void *outer_func(void *arg)
{
  pthread_t inner_thread;

  if (pthread_create(&inner_thread, NULL, inner_func, NULL) != 0) {
    printf("Error: Failed to create new thread.\n");
    exit(1);
  }

  while (1) {
    puts("outer");
  }

  return NULL;
}

int main()
{
  pthread_t outer_thread;

  if (pthread_create(&outer_thread, NULL, outer_func, NULL) != 0) {
    printf("Error: Failed to create new thread.\n");
    exit(1);
  }

  sleep(1);

  if (pthread_kill(outer_thread, SIGTERM) <  0) {
    perror("pthread_kill failed");
  }

  // 到達しない
  puts("main");

  return 0;
}
