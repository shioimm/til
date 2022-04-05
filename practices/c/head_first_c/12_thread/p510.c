// Head First C P510

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <pthread.h>

int beers = 2000000;

void error(char *msg)
{
  fprintf(stderr, "%s: %s\n", msg, strerror(errno));
  exit(1);
}

void *drink_lots(void *a)
{
  int i;

  for (i = 0; i < 100000; i++) {
    beers = beers - 1;
  }

  return NULL;
}

int main()
{
  pthread_t threads[20];
  int t;

  printf("%i beers on the wall.\n%i beers.\n", beers, beers);

  for (t = 0; t < 20; t++) {
    if (pthread_create(&threads[t], NULL, drink_lots, NULL) == -1) {
      error("Can't create thread");
    }
  }

  void *result;

  for (t = 0; t < 20; t++) {
    if (pthread_join(threads[t], &result) == -1) {
      error("Can't join thread");
    }
  }

  printf("Now %i beers on the wall.\n", beers);
  return 0;
}

// gcc p510.c -lpthread -o p510 && ./p510
