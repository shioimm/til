// Head First C P274

#include <stdio.h>

typedef struct island {
  char *name;
  char *opens;
  char *closes;
  struct island *next;
} island;

void display(island *start)
{
  // *i = i構造体へのポインタ
  island *i = start;

  // i->next = ポインタが指すi構造体のnextフィールド (island構造体へのポインタ)
  for (; i->next != NULL ; i = i->next) {
    printf("name: %s, opens: %s, closes: %s\n",
           i->name,
           i->opens,
           i->closes);
  }
}

int main()
{
  island amity       = { "amity",       "09:00", "17:00", NULL }; // ポインタをNULL = 0に設定
  island craggy      = { "craggy",      "09:00", "17:00", NULL };
  island skull       = { "skull",       "09:00", "17:00", NULL };
  island isla_nublar = { "isla_nublar", "09:00", "17:00", NULL };
  island shutter     = { "shutter",     "09:00", "17:00", NULL };

  amity.next       = &craggy;
  craggy.next      = &isla_nublar;
  isla_nublar.next = &skull;
  skull.next       = &shutter;

  display(&amity);

  return 0;
}
