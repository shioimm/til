// 詳説Cポインタ P96

#include <stdlib.h>
#include <stdio.h>

char *get_line(void)
{
  const size_t size_inc = 10;
  char *buf = malloc(size_inc);
  char *current_pos = buf;
  size_t max_len = size_inc;
  size_t len = 0;
  int c;

  if (current_pos == NULL) {
    return NULL;
  }

  while (1) {
    printf("%p\n", current_pos);
    c = fgetc(stdin);

    if (c == '\n') {
      break;
    }

    if (++len >= max_len) {
      char *new_buf = realloc(buf, max_len += size_inc);
      if (new_buf == NULL) {
        free(buf);
        return NULL;
      }
      current_pos = new_buf + (current_pos - buf);
      buf = new_buf;
    }
    *current_pos++ = c;
  }

  *current_pos = '\0';

  return buf;
}

int main(void)
{
  get_line();

  return 0;
}
