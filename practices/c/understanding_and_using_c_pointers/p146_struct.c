// 詳説Cポインタ P146

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct _person {
  char *name;
  unsigned int age;
} Person;

int main(void)
{
  Person p1;
  p1.name = malloc(strlen("Alice"));
  strcpy(p1.name, "Alice");
  p1.age = 30;
  printf("%s, %d\n", p1.name, p1.age);

  Person *p2;
  p2 = malloc(sizeof(Person));
  p2->name = malloc(sizeof("Bob")); // (*p2).name = malloc(sizeof("Bob"));
  strcpy(p2->name, "Bob"); // strcpy((*p2).name, "Bob");
  p2->age = 40; // (*p2).age = 40

  printf("%s, %d\n", p2->name, p2->age);

  free(p1.name);
  free(p2->name);
  free(p2);

  return 0;
}
