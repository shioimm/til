// 引用: Linuxによる並行プログラミング入門 第4章 リダイレクトとパイプ 4.7

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main()
{
  int wfd, rfd, n;
  char client, cmd[80];

  wfd = open("request", O_WRONLY);
  rfd = open("response2", O_RDONLY);

  client = '2';

  for (;;) {
    printf("首都を探します。国名の番号を入力してください");
    printf("0:終了 1:日本 2:アメリカ 3:ロシア");
    if (fgets(cmd, 80, stdin) == NULL) {
      exit(0);
    }
    write(wfd, &client, 1);
    write(wfd, cmd, 1);

    n = read(rfd, cmd, 80);
    cmd[n] = '\0';
    printf("回答: %s\n\n", cmd);
  }
}
