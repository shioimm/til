#include <stdio.h>
#include <pthread.h>

pthread_mutex_t m;
int number;

typedef struct {
  char sign;
} data;

void *gate(void *arg)
{
  data *d = (data *)arg;

  for (;;) {
    pthread_mutex_lock(&m);
    if (d->sign == 'a') {
      number = -1;
    } else if (d->sign == 'b') {
      number = 1;
    }
    pthread_mutex_unlock(&m);

    if (number == 0 || number == -1 || number == 1) {
      puts("OK");
    } else {
      puts("Error!");
    }
  }
}

int main()
{
  pthread_t alice, bob;
  data alice_arg = { 'a' };
  data bob_arg   = { 'b' };

  pthread_mutex_init(&m, NULL);

  pthread_create(&alice, NULL, &gate, (void *)&alice_arg);
  pthread_create(&bob,   NULL, &gate, (void *)&bob_arg);

  pthread_join(alice, NULL);
  pthread_join(bob,   NULL);

  pthread_mutex_destroy(&m);

  return 0;
}
