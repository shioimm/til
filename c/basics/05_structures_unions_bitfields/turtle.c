/*
 * 引用: head first c
 * 第5章 構造体、共用体、ビットフィールド 4
*/

#include <stdio.h>

typedef struct {
  const char *name;
  const char *species;
  int age;
} turtle;

void happy_birthday(turtle *t) /* tへのポインタを引数に受け取る */
{
  (*t).age = (*t).age + 1; /* ポインタではなく値にアクセスする */
  printf("誕生日おめでとう、%s!これで%i歳ですね！\n",
         (*t).name, (*t).age);

  /*
   * (*t).ageはポインタ*tが持つageの値を示す
   * *t.ageとすると、t.ageが示すメモリ位置の内容を示す(= *(t.age))
   *   -> t.ageはメモリ位置ではないためこの式は誤っている
  */

  /*
   * (*t).ageはt->ageに置き換えられる
   * t->ageはtが指すstructのageフィールドの値を表す
   *   t->age = t->age + 1;
   *   printf("誕生日おめでとう、%s!これで%i歳ですね！\n",
   *          t->name, t->age);
  */
}

int main()
{
  turtle myrtle = { "マートル", "オサガメ", 99 };

  happy_birthday(&myrtle); /* myrtleのポインタを引数として渡す */
  printf("%sの年齢は%i歳です\n",
         myrtle.name, myrtle.age);

  return 0;
}
