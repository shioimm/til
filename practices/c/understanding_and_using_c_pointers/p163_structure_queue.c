// 詳説Cポインタ P163

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

typedef LinkedList Queue;

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

void init_queue(Queue *queue)
{
  init_list(queue);
}

void enqueue(Queue *queue, void *node)
{
  add_head(queue, node);
}

void *dequeue(Queue *queue)
{
  Node *tmp = queue->head;
  void *data;

  if (queue->head == NULL) {
    data = NULL;
  } else if (queue->head == queue->tail) {
    queue->head = queue->tail = NULL;
    data = tmp->data;
    free(tmp);
  } else {
    while (tmp->next != queue->tail) {
      tmp = tmp->next;
    }

    queue->tail = tmp;
    tmp = tmp->next;
    queue->tail->next = NULL;
    data = tmp->data;
    free(tmp);
  }

  return data;
}

int main(void)
{
  Queue *queue = malloc(sizeof(Queue));

  Employee *alice = malloc(sizeof(Employee));
  strcpy(alice->name, "Alice");
  alice->age = 30;

  Employee *bob = malloc(sizeof(Employee));
  strcpy(bob->name, "Bob");
  bob->age = 40;

  Employee *carol = malloc(sizeof(Employee));
  strcpy(carol->name, "Carol");
  carol->age = 50;

  init_queue(queue);

  enqueue(queue, alice);
  enqueue(queue, bob);
  enqueue(queue, carol);

  void *data;
  data = dequeue(queue);
  printf("Dequeued %s\n", ((Employee*)data)->name);

  data = dequeue(queue);
  printf("Dequeued %s\n", ((Employee*)data)->name);

  data = dequeue(queue);
  printf("Dequeued %s\n", ((Employee*)data)->name);

  return 0;
}
