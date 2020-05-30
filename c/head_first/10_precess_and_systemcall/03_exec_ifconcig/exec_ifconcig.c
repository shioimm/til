/*
 * 引用: Head First C
 * 第10章 プロセスとシステムコール 3
*/

#include <stdio.h>  /* fprintf() */
#include <string.h> /* strerror() */
#include <unistd.h> /* execl() / execlp() */
#include <errno.h>  /* errno変数 */

int main()
{
  /* 実行失敗時の返り値-1を補足 */
  if (execl("/sbin/ifconfig", "/sbin/ifconfig", NULL) == -1) { /* 絶対パスによる検索を試行 */
    if (execlp("ifconfig", "ifconfig", NULL) == -1) {          /* PATHによる検索を試行 */
      fprintf(stderr, "ifconfigを実行できません: %s\n", strerror(errno));
      return 1;
    }
  }
  return 0;
}
