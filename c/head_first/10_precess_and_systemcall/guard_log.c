/*
 * 引用: Head First C
 * 第10章 プロセスとシステムコール
*/

/*
 * システムコール
 *   OSのカーネルの機能を呼び出すために使用される
 *   カーネル内に実装されている関数
*/
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

char* now() // ポインタを返す
{
  time_t t;  /* 時刻情報の格納先 */
  time (&t); /* 時刻情報を取得し、格納先へのポインタを渡す */

  return asctime(localtime (&t));
  /* 現在時刻のタイムスタンプを返す */
  /* asctime -> tm構造体のオブジェクトを文字列に変換  */
  /* localtime -> calendartimeをlocaltimeに変換 */
}

int main()
{
  char comment[80];
  char cmd[120];

  fgets(comment, /* 入力をcommentに格納*/
        80,      /* 80文字分のメモリを確保 */
        stdin);  /* 標準入力 */

                   /* sprintf -> 文字を文字列に出力 */
  sprintf(cmd,     /* フォーマット化された文字列をcmd配列に格納 */
          "echo '%s %s' >> reports.log", /* コマンドテンプレート */
          comment, /* reports.logの末尾に追加するcomment */
          now());  /* reports.logの末尾に追加するタイムスタンプ */

  system(cmd); /* cmdを呼び出す */

  return 0;
}
