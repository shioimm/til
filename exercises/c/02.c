/*
 * 納得C言語 [第8回]演習問題Ⅱ
 * http://www.isl.ne.jp/pcsp/beginC/C_Language_08.html
*/

#include <stdio.h>

int compare(int correct, int answer)
{
  if (answer > correct) {
    puts("It's bigger than correct number.");
    return 1;
  } else if (answer < correct) {
    puts("It's smaller than correct number.");
    return 1;
  } else {
    puts("It's a correct number.");
    return 0;
  }
}

int main()
{
  int correct, count, answer;

  printf("Enter number of answer -> ");
  scanf("%i", &correct);


  for (count = 0; count < 3; count++) {
    printf("What number did you input? -> ");
    scanf("%i", &answer);

    if (compare(correct, answer) == 0) {
      break;
    } else if (count == 2) {
      printf("The correct number is %i\n", correct);
    }
  }

  return 0;
}
