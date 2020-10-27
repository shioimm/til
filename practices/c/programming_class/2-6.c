// 例解UNIX/Linuxプログラミング教室 P82

#include <stdio.h>
#include <stdlib.h>

struct point {
  int x, y;
};

struct point *make_point(int x, int y)
{
  struct point *p = malloc(sizeof(struct point));
  p->x = x;
  p->y = y;

  return p;
}

int main()
{
  int x = 0;
  int y = 0;
  struct point *new;

  while (1) {
    new = make_point(x, y);
    printf("(%d, %d)", new->x, new->y);
    x++;
    y++;
    free(new);
  }

  return 0;
}
