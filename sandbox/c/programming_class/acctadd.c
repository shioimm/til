// 参照: 例解UNIX/Linuxプログラミング教室P174

#include <stdio.h>
#include <string.h>
#include <time.h>

#define ACCTBOOK "acctbook.txt"

enum {
  MAXLINELEN = 80,
  BUFLEN = MAXLINELEN + 1,
};

int main()
{
  FILE *fp;
  char buf[BUFLEN];
  char item[BUFLEN], value[BUFLEN];
  time_t unixtime;
  struct tm now;
  int year, month, day;
  double val;
  char *p;

  unixtime = time(NULL);
  localtime_r(&unixtime, &now);

  year = now.tm_year + 1900;
  month = now.tm_mon + 1;
  day = now.tm_mday;

  fp = fopen(ACCTBOOK, "a");

  for (;;) {
    fputs("item? ", stderr);
    fgets(item, sizeof(item), stdin);
    if (feof(stdin)) {
      break;
    }
    if ((p = strchr(item, '\n')) != NULL) {
      *p = '\0';
    }

    fputs("value? ", stderr);
    fgets(value, sizeof(value), stdin);
    if (sscanf(value, "%lf", &val) != 1) {
      fprintf(stderr, "value \"%s\" invalud; ignored\n", value);
      continue;
    }

    if (snprintf(buf, sizeof(buf), "%04d/%02d/%02d %.2f %s\n", year, month, day, val, item) >= sizeof(buf)) {
      buf[sizeof(buf) - 2] = '\n';
      fprintf(stderr, "warning: entry too long; truncated to: %s\n", buf);
    }

    fputs(buf, fp);
  }

  fclose(fp);
  putc('\n', stderr);

  return 0;
}
