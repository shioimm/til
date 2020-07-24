/*
 * 引用: Head First C
 * 第12章 スレッド 1
*/

/*
 * スレッド関数
 *   POSIXスレッドライブラリ(pthread)を使用する
 *   戻り値はvoidポインタ
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <pthread.h> /* pthread_create() */

void error(char *msg)
{
  fprintf(stderr, "%s: %s\n", msg, strerror(errno));
  exit(1);
}

void* does_not(void *a)
{
  int i = 0;
  for (i = 0; i < 5; i++) {
    sleep(1);
    puts("Does not!");
  }
  return NULL;
}

void* does_too(void *a)
{
  int i = 0;
  for (i = 0; i < 5; i++) {
    sleep(1);
    puts("Does too!");
  }
  return NULL;
}

int main()
{
  /*
   * pthread_t
   *   スレッド構造体
   *   スレッドに関する全情報を格納する
  */
  pthread_t t0;
  pthread_t t1;

  /*
   * pthread_create
   *   int pthread_create(pthread_t *thread, pthread_attr_t *attr, void *(*start_routine)(void *), void *arg);
   *   スレッドを生成して実行
  */
  if (pthread_create(&t0, NULL, does_not, NULL) == -1) {
    error("スレッドt0を作成できません");
  } else if (pthread_create(&t1, NULL, does_too, NULL) == -1) {
    error("スレッドt1を作成できません");
  }

  void *result;

  /*
   * pthread_join
   *   int pthread_join(pthread_t th, void **thread_return);
   *   全てのスレッドが完了するまで待つ
   *   スレッド関数の返り値を受け取り、voidポインタ変数resultに格納する
   *   両方のスレッドが完了するとプログラムは終了する
  */
  if (pthread_join(t0, &result) == -1){
    error("スレッドt0をジョインできません");
  } else if (pthread_join(t1, &result) == -1){
    error("スレッドt1をジョインできません");
  }

  return 0;
}
