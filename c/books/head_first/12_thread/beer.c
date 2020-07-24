/*
 * 引用: Head First C
 * 第12章 スレッド 2
*/

/*
 * 複数のスレッドが同じ教養変数を読み書きする場合、スレッドセーフではない
 * スレッドが互いに衝突するのを防ぐためにミューテックス(相互排他)が必要
 *   pthread_mutex_t mutex_t = PTHREAD_MUTEX_INITIALIZER;
 *   pthread_mutex_lock(&mutex_t);   一つのスレッドのみプログラムを実行させる開始地点
 *   pthread_mutex_unlock(&mutex_t); 一つのスレッドのみプログラムを実行させる終了地点
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <pthread.h>

int beers = 2000000;
pthread_mutex_t beers_lock = PTHREAD_MUTEX_INITIALIZER;

void *drink_lots(void *a)
{
  int i;
  pthread_mutex_lock(&beers_lock);

  for (i = 0; i < 100000; i++) {
    beers = beers - 1;
  }

  pthread_mutex_unlock(&beers_lock);
  printf("beers = %i\n", beers);

  return NULL;
}

int main()
{
  pthread_t threads[20];
  int t;

  printf("壁にはビールが%i本\n%i本のビール\n", beers, beers);

  for (t = 0; t < 20; t++) {
    pthread_create(&threads[t], NULL, drink_lots, NULL);
  }

  void *result;
  for (t = 0; t < 20; t++) {
    pthread_join(threads[t], &result);
  }

  printf("現在、壁にはビールが%i本あります\n", beers);

  return 0;
}
