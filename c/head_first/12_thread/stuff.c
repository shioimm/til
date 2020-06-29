/*
 * 引用: Head First C
 * 第12章 スレッド 3
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <pthread.h>

void *do_stuff(void *param)
{
  long thread_no = (long)param;
  printf("スレッド番号%ld\n", thread_no);

  return (void*)(thread_no + 1);
}

int main()
{
  pthread_t threads[20];
  long t;

  for (t = 0; t < 3; t++) {
    pthread_create(&threads[t], NULL, do_stuff, (void*)t);
  }

  void *result;
  for (t = 0; t < 3; t++) {
    pthread_join(threads[t], &result);
    printf("スレッド%ldは%ldを返しました\n", t, (long)result);
  }

  return 0;
}

