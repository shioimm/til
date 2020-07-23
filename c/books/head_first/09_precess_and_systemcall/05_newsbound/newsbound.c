/*
 * 引用: Head First C
 * 第10章 プロセスとシステムコール 5
*/

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

int main(int argc, char *argv[])
{
  char *feeds[] = {
    "http://www.cnn.com/rss/cerebs.xml",
    "http://www.rollingstone.com/rock.xml",
    "http://eoline.com/gossip.xml",
  };

  int times = 3;
  char *phrase = argv[1]; /* 検索語 */
  int i;

  for (i = 0; i < times; i++) {
    char var[255];
    sprintf(var, "RSS_FEED=%s", feeds[i]);
    char *vars[] = { vars, NULL };

    /* 毎回exec関数を実行できるように子プロセスをfork() */
    pid_t pid = fork(); /* 正常系で0 / 異常系で-1を返す */

    if (pid == -1) {
      fprintf(stderr, "プロセスをフォークできません:%s\n", strerror(errno));
      return 1;
    }

    /* !pidはpid == 0は同じ */
    if (!pid) {
      /*
       * 子プロセスでexec関数を実行
       * ./rssgossip.py -> Pythonスクリプト
       * phrase         -> 検索語
       * vars           -> 追加パラメータ
      */
      if (execle("/usr/bin/python", "/usr/bin/python", "./rssgossip.py", phrase, NULL, vars) == 1) {
        fprintf(stderr, "スクリプトを実行できません:%s\n", strerror(errno));
        return 1;
      }
      /* $ ./newsbound 'pajama death' */
    }

  }

  return 0;
}
