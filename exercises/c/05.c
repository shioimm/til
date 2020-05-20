/*
 * 納得C言語 [第12回]演習問題Ⅲ
 * http://www.isl.ne.jp/pcsp/beginC/C_Language_12.html
*/

#include <stdio.h>

float avg(int grades[3][2]);

int main()
{
  int grades[3][2];
  int i, ii;

  puts("Enter the scores");

  for (i = 0; i < 3; i++) {
    printf("No.%d:", i + 1);

    scanf("%d", &grades[i][0]);

    if ((grades[i][0] < 0) || (grades[i][0] > 100)) {
      puts("Invalid score. Enter again.");
      i--;
      continue;
    }
  }

  for (i = 0; i < 3; i++) {
    grades[i][1] = 1;
  }

  for (i = 0; i < 3; i++) {
    for (ii = 0; ii < 3; ii++) {
      if (grades[i][0] > grades[ii][0]) {
        grades[ii][1]++;
      }
    }
  }

  for (i = 0; i < 3; i++) {
    printf("No.%d-> score: %d, rank: %d\n", i + 1, grades[i][0], grades[i][1]);
  }

  printf("Avg: %.2f\n", avg(grades));

  return 0;
}

float avg(int grades[3][2])
{
  int sum = 0, i = 0;

  for (; i < 3; i++) {
    sum = sum + grades[i][0];
  }

  return (float)(sum / 3.0);
}
