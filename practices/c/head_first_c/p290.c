// Head First C P290

#include <stdio.h>
#include <stdlib.h> // malloc, free
#include <string.h> // strdup - 文字列の長さを求め、mallocを呼び出して文字列をヒープにコピー

typedef struct island {
  char *name;
  char *opens;
  char *closes;
  struct island *next;
} island;

void display(island *start)
{
  island *i = start;

  for (; i != NULL; i = i->next) {
    printf("name: %s, opens: %s, closes: %s\n",
           i->name,
           i->opens,
           i->closes);
  }
}

island* create(char *name)
{
  island *i = malloc(sizeof(island));

  i->name   = strdup(name);
  i->opens  = "09:00";
  i->closes = "17:00";
  i->next   = NULL;

  return i;
}

void release(island *start)
{
  island *i = start;
  island *next = NULL;

  for (; i != NULL; i = next) {
    next = i->next;
    free(i->name); // strdupで確保したメモリを削除
    free(i); // mallocで確保したメモリを削除
  }
}

int main()
{
  island *start = NULL;
  island *i     = NULL;
  island *next  = NULL;

  char name[80];

  for (; fgets(name, 80, stdin) != NULL; i = next) {
    next = create(name);

    if (start == NULL) {
      start = next;
    }
    if (i != NULL) {
      i->next = next;
    }
  }

  display(start);
  release(start);

  return 0;
}
