#include <stdio.h>
#include <pthread.h>

int get_value()
{
  int value = 1;
  return value;
}

void *print_value()
{
  printf("value = %d\n", get_value());
  return NULL;
}

int main()
{
  pthread_t threads[10];

  for (int i = 0; i < 10; i++) pthread_create(&threads[i], NULL, &print_value, NULL);
  for (int i = 0; i < 10; i++) pthread_join(threads[i], NULL);

  return 0;
}
