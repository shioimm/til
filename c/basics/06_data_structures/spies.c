/*
 * 引用: head first c
 * 第6章 データ構造と動的メモリ 3
*/

/*
 * 連想配列(連想マップ)
 *   二つの異なる種類のデータを関連づける
 *
 * 連結リスト
 *  一連の項目を格納でき、新しい項目の挿入が容易
 *  一方行にしか操作できない
 *
 * 双方向連結リスト
 *   格納する項目は最大で他の二つの項目に関連づけることができ、
 *   双方向に操作できる
 *
 * 二分木
 *   格納する項目は最大で他の二つの項目に関連づけることができ、
 *   階層的な情報を格納するために用いられる
*/

/* 二分木を利用したシステム */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct node {
  char *question;
  struct node *no;
  struct node *yes;
} node;

int yes_no(char *question)
{
  char answer[3];
  printf("%s? (y/n): ", question);
  fgets(answer, 3, stdin);

  return answer[0] == 'y';
}

node* create(char *question)
{
  node *n = malloc(sizeof(node));
  n->question = strdup(question);
  n->no = NULL;
  n->yes = NULL;

  return n;
}

void release(node *n)
{
  if (n->no) {
    release(n->no);
  }
  if (n->yes) {
    release(n->yes);
  }
  if (n->question) {
    free(n->question);
  }
  free(n);
}

int main()
{
  char question[80];
  char suspect[20];
  node *start_node = create("容疑者は髭を生やしているか");
  start_node->no = create("ロレッタ・バーンスワース");
  start_node->yes = create("ベニー・ザ・スプーン");

  node *current;

  do {
    current = start_node;
    while (1) {
      if (yes_no(current->question)) {
        if (current->yes) {
          current = current->yes;
        } else {
          printf("容疑者判明");
          break;
        }
      } else if (current->no) {
        current = /currecurrent->no;
      } else {
        /* yesノードを新しい容疑者名にする */
        printf("容疑者は誰？");
        fgets(suspect, 20, stdin);
        node *yes_node = create(suspect);
        current->yes = yes_node;

        /* noノードをこの質問のコピーにする */
        node *no_node = create(current->question);
        current->no = no_node;

        /* この質問を新しい質問に置き換える */
        printf("%sには当てはまり、%sには当てはまらない質問は？", suspect, current->question);
        fgets(question, 80, stdin);

        /*
         * current->questionがすでにヒープ上の何かを指している場合、
         * 新しい質問を割り当てる前に開放しておく
        */
        free(current->question;)
        current->question = strdup(question);

        break;
      }
    }
  } while (yes_no("再実行しますか"));

  release(start_node);

  return 0;
}

/*
 * valgrind
 *   ヒープに対して、空間に割り当て可能なデータを監視する
 *   valgrindはmalloc()とfree()の呼び出しを横取りし、
 *   valgrindバージョンのmalloc()とfree()を実行する
 *   どのコード部分がmalloc()を呼び出し、どのメモリを割り当てたか記録する
 *   プログラム終了時、valgrindはヒープに残ったデータを報告し、
 *   どの部分のコードがそのデータを作成したか通知する
 *
 *   $ valgrind --leak-check_full ./spies
*/
/*
 * メモリリークを解決する:
 *   どのような時にリークが発生するかを見つける
 *   リークの発生箇所を特定する
 *   リークが直ったことを確認する
*/
