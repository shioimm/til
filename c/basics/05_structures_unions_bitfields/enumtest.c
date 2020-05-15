/*
 * 引用: head first c
 * 第5章 構造体、共用体、ビットフィールド 7
*/

/*
 * enum変数
 *   シンボルを格納する
 *   enum colors { RED, GREEN, PUSE };
 *     enum colorsで定義した変数にはリスト内のキーワードしか使用できない
 *     ◯ enum colors favorite = PUSE;
 *     × enum colors favorite = PUCE;
*/

#include <stdio.h>

typedef enum {
  COUNT, POUNDS, PINTS
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
  printf("この注文に含まれるものは");

  if (order.units == PINTS) {
    printf("%2.2fパイントの%sです\n", order.amount.volume, order.name);
  } else if (order.units == POUNDS) {
    printf("%2.2fポンドの%sです\n", order.amount.weight, order.name);
  } else {
    printf("%i個の%sです\n", order.amount.count, order.name);
  }
}

int main()
{
  fruit_order apples = { "りんご", "イギリス", .amount.count=144, COUNT };
  fruit_order strawberries = { "いちご", "スペイン", .amount.weight=17.6, POUNDS };
  fruit_order oj = { "オレンジジュース", "アメリカ", .amount.volume=10.5, PINTS };

  display(apples);
  display(strawberries);
  display(oj);

  return 0;
}
