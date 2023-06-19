// 命令ごとにスレッドを割り当て、スレッドごとに処理を行う

#include <stdio.h>
#include <pthread.h>

typedef struct {
  int no;
} Data;

void *print(void *arg)
{
  Data *d = (Data *)arg;
  printf("Op %d\n", d->no);

  return NULL;
}

int main()
{
  pthread_t t[100];
  Data arg[100];

  for (int i = 0; i < 100; i++) arg[i].no = i;
  for (int i = 0; i < 100; i++) pthread_create(&t[i], NULL, &print, &arg[i]);
  for (int i = 0; i < 100; i++) pthread_join(t[i], NULL);

  return 0;
}
