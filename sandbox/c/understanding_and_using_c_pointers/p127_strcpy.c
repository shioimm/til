// 詳説Cポインタ P127

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(void)
{
  char name[] = "FOO";
  char *names[2]; // names is array of pointers to char

  names[0] = malloc(strlen(name) + 1); // ヒープ上に文字列を保存
  strcpy(names[0], name);

  names[1] = name; // スタック上の文字列を参照

  printf("%s\n", names[0]);
  printf("%s\n", names[1]);

  return 0;
}
