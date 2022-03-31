/*
 * 納得C言語 [第12回]演習問題Ⅲ
 * http://www.isl.ne.jp/pcsp/beginC/C_Language_12.html
*/

#include <stdio.h>
#include <string.h>

int main()
{
  char str[256][256];
  int i;

  puts("Enter any phrase -> ");

  while(1) {
    scanf("%s", str[i]);

    if (strcmp(str[i], "END") == 0) {
      i--;
      break;
    }

    i++;
  }

  for (; i >= 0; i--) {
    printf("%s\n", str[i]);
  }

  return 0;
}
