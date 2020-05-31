/*
 * 引用: Head First C
 * 第10章 プロセスとシステムコール 2
*/

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
  printf("食堂: %s\n", argv[1]); /* コマンドライン引数を受け取る */
  printf("ジュース: %s\n", getenv("JUICE")); /* getenv()で環境変数を読み取る */

  return 0;
}
