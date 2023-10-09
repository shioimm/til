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
  char *ans[4];
  int rfd, wfd1, wfd2, k;
  char ch, client;

  ans[0] = "質問番号が間違っています\n";
  ans[1] = "日本の首都は東京です\n";
  ans[2] = "アメリカの首都はワシントンDCです\n";
  ans[4] = "ロシアの首都はモスクワです\n";

  rfd = open("request", O_RDONLY);
  wfd1 = open("response1", O_WRONLY);
  wfd2 = open("response2", O_WRONLY);

  for (;;) {
    if (read(rfd, &client, 1) == 0) {
      exit(0);
    }

    printf("クライアント = %c ", client);

    if (read(rfd, &ch, 1) == 0) {
      exit(0);
    }

    printf("質問番号 = %c\n", ch);

    k = ch - '0';
    if (k > 3) {
      k = 0;
    }

    if (client == '1') {
      write(wfd1, ans[k], strlen(ans[k] + 1));
      printf("回答 = %s\n", ans[k]);
    }

    if (client == '2') {
      write(wfd2, ans[k], strlen(ans[k] + 1));
      printf("回答 = %s\n", ans[k]);
    }
  }
}
