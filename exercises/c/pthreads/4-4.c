// Linuxとpthreadsによるマルチスレッドプログラミング入門 P92

#include <pthread.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

#define N_THREAD          1000
#define MAX_PRIME_NUMBERS 100000

int primeNumber[MAX_PRIME_NUMBERS];
int nPrimeNumber;
pthread_mutex_t usingPrimeNumber;

int isPrimeNumber(int m)
{
  int i;

  for (i = 0; i < nPrimeNumber; i++) {
    if (m % primeNumber[i] == 0) {
      return 0;
    }
  }

  return 1;
}

int countPrimeNumbers(int n)
{
  int i;

  pthread_mutex_lock(&usingPrimeNumber);

  nPrimeNumber = 0;

  for (i = 2; i <= n; i++){
    if (isPrimeNumber(i)) {
      if (nPrimeNumber >= MAX_PRIME_NUMBERS) {
        printf("Oops, too many prim numbers\n");
        exit(1);
      }

      primeNumber[nPrimeNumber] = i;
      nPrimeNumber++;
    }
  }

  i = nPrimeNumber;
  pthread_mutex_unlock(&usingPrimeNumber);

  return i;
}

void *threadFunc(void *arg)
{
  int n = (int)arg;
  int x;

  x = countPrimeNumbers(n);
  printf("Number of prime numbers under %d is %d\n", n, x);

  return NULL;
}

int main()
{
  pthread_t threads[N_THREAD];
  int i;
  pthread_mutex_init(&usingPrimeNumber, NULL);

  for (i = 0; i < N_THREAD; i++) {
    if (pthread_create(&threads[i], NULL, threadFunc, (void *)100) != 0) {
      printf("Can't create thread (%d)\n", i);
      exit(1);
    }
  }

  for (i = 0; i < N_THREAD; i++) {
    pthread_join(threads[i], NULL);
  }

  pthread_mutex_destroy(&usingPrimeNumber);

  printf("Done\n");

  return 0;
}
