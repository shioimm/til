/* リスト */

#include <stdio.h>

typedef struct element {
  char *color;
  struct element *next;
} element;

void display(element *first)
{
  element *i = first;

  for (; i != NULL; i = i->next) {
    printf("%s\n", i->color);
  }
}

int main()
{
  element blue = { "Blue", NULL };
  element yellow = { "Yellow", NULL };
  element red = { "Red", NULL };

  blue.next = &yellow;
  yellow.next = &red;
  display(&blue); /* Blue -> Yellow -> Red */

  puts("----");

  /* greenを挿入 */
  element green = { "Green", NULL };

  blue.next = &green;
  green.next = &yellow;
  display(&blue); /* Blue -> Green -> Yellow -> Red */

  puts("----");

  /* yellowを削除 */
  green.next = &red; /* Blue -> Green -> Red */
  display(&blue);

  return 0;
}
