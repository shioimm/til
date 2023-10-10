// Head First C P230

#include <stdio.h>

struct exercise {
  const char *description;
  float duratioon;
};

struct meal {
  const char *ingredients;
  float weight;
};

struct prefarences {
  struct meal food;
  struct exercise exercise;
};

struct fish {
  const char *name;
  const char *species;
  int teeth;
  int age;
  struct prefarences care;
};

void label(struct fish f)
{
  printf("name: %s, species: %s, teeth: %i, age: %i\n",
         f.name,
         f.species,
         f.teeth,
         f.age);
  printf("meal: %s (%2.2f), exercise: %s (%2.2f)\n",
         f.care.food.ingredients,
         f.care.food.weight,
         f.care.exercise.description,
         f.care.exercise.duratioon);
}

int main()
{
  struct fish snappy = {
    "snappy",
    "piranha",
    69,
    4,
    {
      { "meat", 0.10 },
      { "swimming", 7.50 }
    }
  };
  label(snappy);

  return 0;
}
