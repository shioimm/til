// 詳説Cポインタ P154

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct _employee {
  char name[32];
  unsigned int age;
} Employee;

int compare(Employee *e1, Employee *e2)
{
  return strcmp(e1->name, e2->name);
}

void display(Employee *e)
{
  printf("%s\t%d\n", e->name, e->age);
}

typedef int (*COMPARE)(void*, void*);
typedef void (*DISPLAY)(void*);
