// Thread Per Message + Consumer-Producer

#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

pthread_mutex_t mutex;
pthread_cond_t  cond;

typedef struct {
  int no;
  int taken;
} Task;

Task tasks[100];

void *take_task(void *arg)
{
  int n = (int)arg;

  for (int i = 0; i < 100; i++) {
    pthread_mutex_lock(&mutex);

    if (tasks[i].taken == 0) {
      tasks[i].taken = 1;
      printf("worker %d handles no. %d\n", n, tasks[i].no);
    }

    pthread_mutex_unlock(&mutex);
    usleep(10);
  }

  return NULL;
}

int main()
{
  pthread_t workers[5];

  pthread_mutex_init(&mutex, NULL);

  for (int i = 0; i < 100; i++) {
    tasks[i].no = i;
    tasks[i].taken = 0;
  }

  for (int i = 0; i < 5; i++) pthread_create(&workers[i], NULL, &take_task, (void *)i);
  for (int i = 0; i < 5; i++) pthread_join(workers[i], NULL);

  pthread_mutex_destroy(&mutex);

  return 0;
}
