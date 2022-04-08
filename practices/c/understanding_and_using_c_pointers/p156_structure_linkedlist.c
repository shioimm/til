// 詳説Cポインタ P156

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

void add_tail(LinkedList *list, void *data)
{
  Node *node = malloc(sizeof(Node));
  node->data = data;
  node->next = NULL;

  if (list->head == NULL) {
    list->head = node;
  } else {
    list->tail->next = node;
  }
  list->tail = node;
}

Node *get_node(LinkedList *list, COMPARE compare, void *data)
{
  Node *node = list->head;

  while (node != NULL) {
    if (compare(node->data, data) == 0) {
      return node;
    }
    node = node->next;
  }

  return NULL;
}

void delete_node(LinkedList *list, Node *node)
{
  if (node == list->head) {
    if (list->head->next == NULL) {
      list->head = list->tail = NULL;
    } else {
      list->head = list->head->next;
    }
  } else {
    Node *tmp = list->head;

    while (tmp != NULL && tmp->next != node) {
      tmp = tmp->next;
    }

    if (list->tail == node) {
      list->tail = tmp;
    }
  }
  free(node);
}

void display_list(LinkedList *list, DISPLAY display)
{
  printf("\nlinked list\n");
  Node *current = list->head;
  while (current != NULL) {
    display(current->data);
    current = current->next;
  }
}

int main(void)
{
  LinkedList *list = malloc(sizeof(LinkedList));

  Employee *alice = malloc(sizeof(Employee));
  strcpy(alice->name, "Alice");
  alice->age = 30;

  Employee *bob = malloc(sizeof(Employee));
  strcpy(bob->name, "Bob");
  bob->age = 40;

  Employee *carol = malloc(sizeof(Employee));
  strcpy(carol->name, "Carol");
  carol->age = 50;

  init_list(list);

  add_head(list, alice);
  add_head(list, bob);
  add_head(list, carol);

  // init_list(list);
  // add_tail(list, carol);
  // add_tail(list, bob);
  // add_tail(list, alice);

  display_list(list, (DISPLAY)display);

  Node *node = get_node(list, (int (*)(void*, void*))compare, carol);
  delete_node(list, node);

  display_list(list, (DISPLAY)display);

  return 0;
}
