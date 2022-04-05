// Head First C P240

#include <stdio.h>

typedef struct {
  const char *name;
  const char *spacies;
  int age;
} turtle;

void happy_birthday(turtle *t)
{
  // (*t).age - ポインタが指すt構造体のageフィールド (= t->age)
  // *t.age   - t構造体のageフィールドへのポインタ
  (*t).age = (*t).age + 1;
  printf("Happy Birthday, %s!, You're now %i years old.\n",
         (*t).name,
         (*t).age);
}

int main()
{
  turtle myrtle = { "myrtle", "leatherback turtle", 99 };

  happy_birthday(&myrtle);

  printf("%s is %i years old.\n",
         myrtle.name,
         myrtle.age);

  return 0;
}
