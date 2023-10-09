// Head First C P165

#include <stdio.h>

float total = 0.0;
short count = 1;
short tax_percent = 6;

float add_with_tax(float f) {
  float tax_rate = 1 + tax_percent / 100.0;
  total = total + (f * tax_rate);
  count = count + 1;
  return total;
}

int main(int argc, char *argv[])
{
  float val;
  printf("品目の値段: ");

  while (scanf("%f", &val) == 1) {
    printf("ここまでの合計: %.2f\n", add_with_tax(val));
    printf("品目の値段: ");
  }

  printf("\n最終合計: %.2f\n", total);
  printf("品目数: %hi\n", count);

  return 0;
}
