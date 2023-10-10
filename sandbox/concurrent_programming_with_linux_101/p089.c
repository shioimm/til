// Linuxによる並行プログラミング入門 P88

#include <stdio.h>
#include <pthread.h>

int fn(int *x)
{
  printf("new thread: x = %d\n", *x);
  return (*x) * 2;
}

int main()
{
  pthread_t tid;
  int x = 1;
  int y;

  if ((pthread_create(&tid, NULL, (void *(*)(void *))fn, &x)) != 0) {
    return -1;
  }

  pthread_join(tid, (void **)&y);
  printf("main thread: y = %d\n", y);
  return 0;
}
