// Linuxによる並行プログラミング入門 P86

#include <stdio.h>
#include <pthread.h>

int x;

void fn()
{
  printf("new thread: x = %d\n", x);
}

int main()
{
  pthread_t tid;

  x = 1;

  if ((pthread_create(&tid, NULL, (void *(*)(void *))fn, NULL)) != 0) {
    return -1;
  }

  printf("main thread: x = %d\n", x);
  pthread_join(tid, NULL);
  return 0;
}
