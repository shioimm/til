#include <pthread.h>
#include <stdio.h>

void *nice()
{
  for (int i = 0; i < 1000; i++) puts("Nice!");
}

int main()
{
  pthread_t t;

  pthread_create(&t, NULL, &nice, NULL);

  for (int i = 0; i < 1000; i++) puts("Good!");

  pthread_join(t, NULL);

  return 0;
}
