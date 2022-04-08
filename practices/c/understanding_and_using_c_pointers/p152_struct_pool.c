// 詳説Cポインタ P152

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LISTSIZE 10

typedef struct _person {
  char *name;
  unsigned int age;
} Person;

Person *list[LISTSIZE];

void init_list(void)
{
  for (int i = 0; i < LISTSIZE; i++) {
    list[i] = NULL;
  }
}

Person *get_person(void)
{
  for (int i = 0; i < LISTSIZE; i++) {
    if (list[i] != NULL) {
      Person *p = list[i];
      list[i] = NULL;
      return p;
    }
  }
  Person *p = malloc(sizeof(Person));
  return p;
}

Person *return_person(Person *p)
{
  for (int i = 0; i < LISTSIZE; i++) {
    if (list[i] == NULL) {
      list[i] = p;
      return p;
    }
  }
  free(p->name);
  free(p);
  return NULL;
}

int main(void)
{
  init_list();
  Person *p;
  p = get_person();

  p->name = malloc(sizeof("Alice"));
  strcpy(p->name, "Alice");
  p->age = 30;

  printf("%s, %d\n", p->name, p->age);

  return_person(p);

  return 0;
}
