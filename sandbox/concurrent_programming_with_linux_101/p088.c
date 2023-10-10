// Linuxによる並行プログラミング入門 P88

#include <stdio.h>
#include <pthread.h>

void fn(int *x)
{
  printf("new thread: x = %d\n", *x);
}

int main()
{
  pthread_t tid;
  int x = 1;

  if ((pthread_create(&tid, NULL, (void *(*)(void *))fn, &x)) != 0) {
    return -1;
  }

  printf("main thread: x = %d\n", x);
  pthread_join(tid, NULL);
  return 0;
}
