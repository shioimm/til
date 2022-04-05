// Head First C P258

#include <stdio.h>

typedef enum {
  COUNT,
  POUNDS,
  PINTS
} unit_of_measure;

typedef union {
  short count;
  float weight;
  float volume;
} quantity;

typedef struct {
  const char *name;
  const char *country;
  quantity amount;
  unit_of_measure units;
} fruit_order;

void display(fruit_order order)
{
  printf("Orders: ");

  switch (order.units) {
  case PINTS:
    printf("%s (%2.2f pints)\n", order.name, order.amount.volume);
  case POUNDS:
    printf("%s (%2.2f pounds)\n", order.name, order.amount.weight);
  default:
    printf("%s (%i count)\n", order.name, order.amount.count);
  }
}

int main()
{
  fruit_order apples       = { "apples",       "UK",    .amount.count  = 144,  COUNT  };
  fruit_order strawberries = { "strawberries", "Spain", .amount.weight = 17.6, POUNDS };
  fruit_order oj           = { "orange juice", "US",    .amount.volume = 10.5, PINTS  };

  display(apples);
  display(strawberries);
  display(oj);

  return 0;
}
