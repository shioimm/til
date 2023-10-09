// Linuxによる並行プログラミング入門 P84

#include <stdio.h>
#include <pthread.h>

void fn()
{
  puts("new thread");
}

int main()
{
  pthread_t tid;

  if ((pthread_create(&tid, NULL, (void *(*)(void *))fn, NULL)) != 0) {
    return -1;
  }

  pthread_join(tid, NULL);
  puts("joined");
  return 0;
}
