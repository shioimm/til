// 詳説Cポインタ P166

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct _employee {
  char name[32];
  unsigned int age;
} Employee;

typedef struct _node {
  void *data;
  struct _node *next;
} Node;

typedef struct linked_list {
  Node *head;
  Node *tail;
  Node *current;
} LinkedList;

void init_list(LinkedList *list)
{
  list->head = NULL;
  list->tail = NULL;
  list->current = NULL;
}

void add_head(LinkedList *list, void *data)
{
  Node *node = malloc(sizeof(Node));
  node->data = data;

  if (list->head == NULL) {
    list->tail = node;
    node->next = NULL;
  } else {
    node->next = list->head;
  }
  list->head = node;
}

typedef LinkedList Stack;

void init_stack(Stack *stack)
{
  init_list(stack);
}

void push(Stack *stack, void *data)
{
  add_head(stack, data);
}

void *pop(Stack *stack)
{
  Node *node = stack->head;

  if (node == NULL) {
    return NULL;
  } else if (node == stack->tail) {
    stack->head = stack->tail = NULL;
    void *data = node->data;
    free(node);
    return data;
  } else {
    stack->head = stack->head->next;
    void *data = node->data;
    free(node);
    return data;
  }
}

int main(void)
{
  Stack *stack = malloc(sizeof(Stack));

  Employee *alice = malloc(sizeof(Employee));
  strcpy(alice->name, "Alice");
  alice->age = 30;

  Employee *bob = malloc(sizeof(Employee));
  strcpy(bob->name, "Bob");
  bob->age = 40;

  Employee *carol = malloc(sizeof(Employee));
  strcpy(carol->name, "Carol");
  carol->age = 50;

  init_stack(stack);

  push(stack, alice);
  push(stack, bob);
  push(stack, carol);

  Employee *employee;

  for (int i = 0; i < 4; i++) {
    employee = (Employee*)pop(stack);
    printf("Popped %s\n", employee->name);
  }

  return 0;
}
