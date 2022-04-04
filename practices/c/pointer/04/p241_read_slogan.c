// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SLOGAN_MAX_LEN (1024)

void read_slogan(FILE *fp, char **slogan)
{
  char buf[1024];
  int  slogan_len;
  int  size = 1;
  int  i;

  for (i = 0; i < size; i++) {
    fgets(buf, SLOGAN_MAX_LEN, fp);

    slogan_len = strlen(buf);

    if (buf[slogan_len - 1] != '\n') {
      fprintf(stderr, "too long slogan\n");
      exit(1);
    }
    buf[slogan_len - 1] = '\0';

    slogan[i] = malloc(sizeof(char) * slogan_len);

    strcpy(slogan[i], buf);
  }
}

int main(void)
{
  int   size = 1;
  int   i;
  char *slogan[size];

  read_slogan(stdin, slogan);

  for (i = 0; i < size; i++) {
    printf("%s\n", slogan[i]);
  }

    return 0;
}
