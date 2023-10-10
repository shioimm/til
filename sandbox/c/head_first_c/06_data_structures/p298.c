// Head First C P298

#include <stdio.h>
#include <stdlib.h> // malloc, free
#include <string.h> // strdup - 文字列の長さを求め、mallocを呼び出して文字列をヒープにコピー

typedef struct code {
  char *question;
  struct code *no;
  struct code *yes;
} node;

int yes_no(char *question)
{
  char answer[3];
  printf("%s? (y/n):", question);
  fgets(answer, 3, stdin);

  return answer[0] == 'y';
}

node* create(char *question)
{
  node *n = malloc(sizeof(node));
  n->question = strdup(question);
  n->no = NULL;
  n->yes = NULL;

  return n;
}

void release(node *n)
{
  if (n) {
    if (n->no) {
      release(n->no);
    }
    if (n->yes) {
      release(n->yes);
    }
    if (n->question) {
      free(n->question);
    }
    free(n);
  }
}

int main()
{
  char question[80];
  char suspect[20];

  node *start_node = create("Does the suspect have a beard");
  start_node->no = create("Loretta Barnsworth");
  start_node->yes = create("Vinny the Spoon");

  node *current;

  do {
    current = start_node;

    while (1) {
      if (yes_no(current->question)) {
        if (current->yes) {
          current = current->yes;
        } else {
          printf("Suspect is found\n");
          break;
        }
      } else if (current->no) {
        current = current->no;
      } else {
        printf("Who is the suspect?\n");
        fgets(suspect, 20, stdin);
        node *yes_node = create(suspect);
        current->yes = yes_node;

        node *no_node = create(current->question);
        current->no = no_node;

        printf("Question that is TRUE for %s but not for %s\n",
               suspect,
               current->question);
        fgets(question, 80, stdin);
        free(current->question);
        current->question = strdup(question);

        break;
      }
    }
  } while (yes_no("Retry"));

  release(start_node);

  return 0;
}
