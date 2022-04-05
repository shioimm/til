// Head First C P340

#include <stdio.h>

enum response_type {
  DUMP,
  SECOND_CHANCE,
  MARRIAGE
};

typedef struct {
  char *name;
  enum response_type type;
} response;

void dump(response r)
{
  printf("DUMP to %s\n", r.name);
}

void second_chance(response r) {
  printf("SECOND_CHANCE to %s\n", r.name);
}

void marriage(response r) {
  printf("MARRIAGE to %s\n", r.name);
}

void(*replies[])(response) = { dump, second_chance, marriage };

int main()
{
  response r[] = {
    { "Mike", DUMP },
    { "Lewis", SECOND_CHANCE },
    { "Matt", SECOND_CHANCE },
    { "William", MARRIAGE }
  };

  int i;

  for (i = 0; i < 4; i++) {
    replies[r[i].type](r[i]);
  }

  return 0;
}
