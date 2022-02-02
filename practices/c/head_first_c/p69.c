// Head First C P60

#include <stdio.h>

int main()
{
  // 文字列リテラル"JQK"は定数領域にロードされる
  // char *cards = "JQK"; 定数領域へのポインタなのでメモリを書き換えられない

  // スタック領域へ配列を作成し、文字列リテラル"JQK"を定数領域からコピーしてきて格納する
  char cards[] = "JQK"; // スタック領域へのポインタ
  char a_card = cards[2]; // K

  cards[2] = cards[1]; // JQQ
  cards[1] = cards[0]; // JJQ
  cards[0] = cards[2]; // QJQ
  cards[2] = cards[1]; // QJJ
  cards[1] = a_card;   // QKJ

  puts(cards);
  return 0;
}
