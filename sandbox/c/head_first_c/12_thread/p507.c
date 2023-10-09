// Head First C P507

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <pthread.h>

void* does_not(void *a)
{
  int i = 0;

  for (i = 0; i < 5; i++) {
    sleep(1);
    puts("Does not");
  }

  return NULL;
}

void* does_too(void *a)
{
  int i = 0;

  for (i = 0; i < 5; i++) {
    sleep(1);
    puts("Does too");
  }

  return NULL;
}

void error(char *msg)
{
  fprintf(stderr, "%s: %s\n", msg, strerror(errno));
  exit(1);
}

int main()
{
  pthread_t t0;
  pthread_t t1;

  if (pthread_create(&t0, NULL, does_not, NULL) == -1) {
    error("Can't create t0");
  }
  if (pthread_create(&t1, NULL, does_too, NULL) == -1) {
    error("Can't create t1");
  }

  void *result;

  if (pthread_join(t0, &result) == -1) {
    error("Can't join t0");
  }
  if (pthread_join(t1, &result) == -1) {
    error("Can't join t1");
  }

  return 0;
}

// gcc p507.c -lpthread -o p507 && ./p507
