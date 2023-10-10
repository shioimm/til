// Head First C P224

#include <stdio.h>

// structは固定長
struct fish {
  const char *name;
  const char *species;
  int teeth;
  int age;
};

void catalog(struct fish f)
{
  printf("name is %s, species is %s, tooth are %i, age is %i\n",
         f.name,
         f.species,
         f.teeth,
         f.age);
}

void label(struct fish f)
{
  printf("name: %s, species: %s, teeth: %i, age: %i\n",
         f.name,
         f.species,
         f.teeth,
         f.age);
}

int main()
{
  struct fish snappy = { "snappy", "piranha", 69, 4 };
  catalog(snappy);
  label(snappy);

  return 0;
}
