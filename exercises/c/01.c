/*
 * 納得C言語 [第5回]演習問題Ⅰ & [第8回]演習問題Ⅱ
 * http://www.isl.ne.jp/pcsp/beginC/C_Language_05.html
 * http://www.isl.ne.jp/pcsp/beginC/C_Language_08.html
*/

#include <stdio.h>

int main()
{
  int kind, n_1, n_2, answer;

  while (1) {
    puts("Choose kind.");
    puts("+ -> 1 | - -> 2 | * -> 3 | / -> 4 | exit -> 0");
    scanf("%i", &kind);

    if (kind == 0) {
      puts("Exit");
      break;
    } else if (kind != 1 && kind != 2 && kind != 3 && kind != 4) {
      puts("Incorrect kind.");
      continue;
    }

    puts("Enter number twice");
    printf("a = ");
    scanf("%i", &n_1);
    printf("b = ");
    scanf("%i", &n_2);

    switch (kind) {
      case 1:
        answer = n_1 + n_2;
        printf("%i + %i = %i\n", n_1, n_2, answer);
        break;
      case 2:
        answer = n_1 - n_2;
        printf("%i - %i = %i\n", n_1, n_2, answer);
        break;
      case 3:
        answer = n_1 * n_2;
        printf("%i * %i = %i\n", n_1, n_2, answer);
        break;
      case 4:
        answer = n_1 / n_2;
        printf("%i / %i = %i\n", n_1, n_2, answer);
        break;
    }
  }

  return 0;
}
