// Head First C P336

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
    switch (r[i].type) {
      case DUMP:
        dump(r[i]);
        break;
      case SECOND_CHANCE:
        second_chance(r[i]);
        break;
      case MARRIAGE:
        marriage(r[i]);
        break;
    }
  }

  return 0;
}
