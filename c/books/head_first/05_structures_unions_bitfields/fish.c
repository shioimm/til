/*
 * 引用: head first c
 * 第5章 構造体、共用体、ビットフィールド 1
*/

/*
 * struct
 *   構造体データ型
 *   一連の他のデータ型から作成したデータ型
 *   固定長
 *   構造体の中のデータには名前がついている
 *   structフィールドはコードの順序と同じ順番でメモリに格納される
*/
#include <stdio.h>

struct exercise {
  const char *description; /* 文字列へのポインタ */
  float duration;          /* 記憶領域 */
};

struct meal {
  const char *ingredients; /* 文字列へのポインタ */
  float weight;            /* 記憶領域 */
};

struct preferences {
  struct meal food;         /* 構造体内の構造体(ネスティング) */
  struct exercise exercise; /* 構造体内の構造体(ネスティング) */
};

struct fish {
  const char *name;         /* 文字列へのポインタ */
  const char *species;      /* 文字列へのポインタ */
  int teeth;                /* 記憶領域 */
  int age;                  /* 記憶領域 */
  struct preferences care;  /* 構造体内の構造体(ネスティング) */
};

void catalog(struct fish f) /* 引数に構造体を渡す */
{
  printf("%sは%sであり、歯は%i本あります。年齢は%i歳です。\n",
         f.name, f.species, f.teeth, f.age);
  printf("%sが好む食べ物は%sです。\n",
         f.name, f.care.food.ingredients);
  printf("%sが好む運動時間は%2.2f時間です。\n",
         f.name, f.care.exercise.duration);
}

void label(struct fish f) /* 引数に構造体を渡す */
{
  printf("名前: %s\n種類: %s\n%i本の歯、%i歳\n",
         f.name, f.species, f.teeth, f.age);
  printf("餌は%2.2fキロの%sを与え、%sを%2.2f時間行わせます。\n",
         f.care.food.weight, f.care.food.ingredients, f.care.exercise.description, f.care.exercise.duration);
}

int main()
{
  /*
   * structの定義時点ではメモリは確保されず、
   * 新しい変数を定義した時点で
   * structインスタンスのためのメモリ空間が確保される
   * (構造体全てのフィールドを収納できるサイズ)
  */
  struct fish snappy = { "スナッピー", "ピラニア", 69, 4, { { "肉", 0.1 }, { "ジャクジーでの泳ぎ", 7.5 } } };

  catalog(snappy);
  label(snappy);

  /*
   * struct変数を別の変数に代入すると、
   * 構造体の新しいコピーが別のメモリ空間に作成される
   * snappyと同じサイズのメモリ領域が割り当てられる
   * nameとspeciesは同じメモリを共有している
  */
  struct fish gnasher = snappy;

  catalog(gnasher);
  label(gnasher);

  return 0;
}
