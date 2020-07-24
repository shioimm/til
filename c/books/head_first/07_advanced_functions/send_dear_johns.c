/*
 * 引用: head first c
 * 第7章 高度な関数 3
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

enum response_type { DUMP, SECOND_CHANCE, MARRIAGE };

typedef struct {
  char *name;
  enum response_type type;
} response;

void dump(response r)
{
  printf("%sさんへ\n", r.name);
  printf("残念ながら、前回のデートの結果、");
  printf("再度お会いすることはないとの連絡を受けました。\n");
}

void second_chance(response r)
{
  printf("%sさんへ\n", r.name);
  printf("よいお知らせです。前回のデートの結果、");
  printf("もう一度お会いしたいとの連絡を受けました。至急ご連絡ください。\n");
}

void marriage(response r)
{
  printf("%sさんへ\n", r.name);
  printf("おめでとうございます！前回のデートの結果、");
  printf("結婚を申し込みたいとの連絡を受けました。\n");
}

int main()
{
  response r[] = {
    { "マイク", DUMP },
    { "ルイス", SECOND_CHANCE },
    { "マット", SECOND_CHANCE },
    { "ウィリアム", MARRIAGE },
  };

  int i;
  void (*replies[])(response) = { dump, second_chance, marriage };
  /*
   * 関数ポインタの配列を生成
   *   -> 関数の戻り値の型 | ポインタ変数 | 引数 = { 関数ポインタ配列 }
   *      void         配列内の各関数の返り値がvoidであることを宣言
   *      (*replies[]) 関数ポインタ全体の配列を宣言
   *      (response)   response型の引数を定義
  */

  for (i = 0; i < 4; i++) {
    (replies[r[i].type])(r[i]);
    /*
     * r[i]
     *   -> r配列の各要素(response構造体)
     *
     * replies[r[i].type](r[i])↲
     *   -> enumの値をreplies配列のインデックスとして使用
     *      replies[DUMP]          -> dump()関数
     *      replies[SECOND_CHANCE] -> second_chance()関数
     *      replies[MARRIAGE]      -> marriage()関数
     *      各関数には引数としてresponse構造体r[i]を渡す
    */
  }

  return 0;
}
