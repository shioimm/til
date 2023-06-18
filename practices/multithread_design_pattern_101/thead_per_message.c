// 命令ごとにスレッドを割り当て、スレッドごとに処理を行う

#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

typedef struct {
  char *message;
  int count;
} MessageAndCount;

void *message(void *arg)
{
  MessageAndCount *mac = (MessageAndCount *)arg;

  for (int i = 0; i < mac->count; i++) {
    printf("%s\n", mac->message);
  }

  return NULL;
}

int main()
{
  pthread_t t1, t2, t3;

  MessageAndCount arg1 = { "Apple", 10 };
  MessageAndCount arg2 = { "Banana", 20 };
  MessageAndCount arg3 = { "Chocolate", 30 };

  pthread_create(&t1, NULL, &message, &arg1);
  pthread_create(&t2, NULL, &message, &arg2);
  pthread_create(&t3, NULL, &message, &arg3);

  sleep(1);

  return 0;
}
