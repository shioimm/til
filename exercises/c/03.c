/*
 * 納得C言語 [第12回]演習問題Ⅲ
 * http://www.isl.ne.jp/pcsp/beginC/C_Language_12.html
*/

#include <stdio.h>

int is_leap(int year);

int main()
{
  int year;

  printf("Enter any year -> ");
  scanf("%d", &year);

  if (is_leap(year)) {
    printf("%d is a leap year.", year);
  } else {
    printf("%d is not a leap year.", year);
  }

  return 0;
}

int is_leap(int year)
{
  if ((year % 400 == 0) || (year % 4 == 0 && year % 100 != 0)) {
    return 1;
  } else {
    return 0;
  }
}
