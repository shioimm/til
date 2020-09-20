// 例解UNIX/Linuxプログラミング教室 P162

#include <stdio.h>
#include <stdlib.h>
#include "mysub.h"

enum {
  MAXLINE = 1024,
};

void writediary(void);
void readdiary(void);

int main(void)
{
  int cmd;

  for (;;) {
    cmd = getint("1=write, 2=read, 3=end ");

    switch (cmd) {
      case 1:
        writediary();
        break;
      case 2:
        readdiary();
        break;
      case 3:
        return 0;
      default:
        fputs("unknown command\n", stderr);
    }
  }
}

void writediary(void)
{
  FILE *fp;
  char date[MAXLINE], s[MAXLINE];

  getstr("date (MMDD): ", date, sizeof(date));
  fp = fopen(date, "w");

  while (fgets(s, sizeof(s), stdin) != NULL) {
    fputs(s, fp);
  }

  if (feof(stdin)) {
    clearerr(stdin);
  } else {
    perror("fgets");
    exit(1);
  }

  fclose(fp);

  return;
}

void readdiary(void)
{
  FILE *fp;
  char date[MAXLINE], s[MAXLINE];

  getstr("date (MMDD): ", date, sizeof(date));
  fp = fopen(date, "r");

  while (fgets(s, sizeof(s), fp) != NULL) {
    fputs(s, stdout);
  }

  if (ferror(fp)) {
    perror("fgets");
    exit(1);
  }

  return;
}
