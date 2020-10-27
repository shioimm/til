// Linuxとpthreadsによるマルチスレッドプログラミング入門 P80

#include <pthread.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

#define MAX_PRIME_NUMBERS 100000

int primeNumber[MAX_PRIME_NUMBERS];
int nPrimeNumber;

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
  return nPrimeNumber;
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
  pthread_t thread1, thread2;

  pthread_create(&thread1, NULL, threadFunc, (void *)100000);
  pthread_create(&thread2, NULL, threadFunc, (void *)200000);

  pthread_join(thread1, NULL);
  pthread_join(thread2, NULL);

  return 0;
}
