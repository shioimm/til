/*
 * 引用: Head First C
 * 第1章 Cを始める コードマグネット
*/

#include <stdio.h>
#include <stdlib.h>

int main()
{
    char card_name[3];
    int count = 0;

    do {
        puts("カード名を入力してください");
        scanf("%2s", card_name);
        int val = 0;

        switch(card_name[0]) {
        case 'K':
        case 'Q':
        case 'J':
          val = 10;
          break;
        case 'A':
          val = 11;
          break;
        case 'X':
          continue;
        default:
          val = atoi(card_name); /* テキストを数値に変換 */

          if ((val < 1) || (val > 10)) {
            puts("その値はわかりません");
            continue;
          }
        }

        if ((val >= 3) && (val <= 6)) {
          count++;
        } else if (val == 10) {
          count--;;
        }

        printf("現在のカウント: %i\n", count);
    } while (card_name[0] != 'X');

    return 0;
}

/*
 * 文字列の種類
 *
 * 1) 文字列配列
 * char型(シングルクオーテーションで囲まれた文字)の要素の配列
 * 配列の最後の要素として、文字列の終端を示す番兵としてNull文字を置く
 * s = { 'S', 'h', 'a', 't', 'n', 'e', 'r', '0\' }
 * char card_name[3]; <- 要素数に番兵文字を含まれる
 *
 * 2) 文字列リテラル
 * ダブルクオーテーションで囲まれた文字列
 * 定数であり変更できない
*/

/*
 * 真偽値
 *
 * 0 -> 偽
 * それ以外 -> 真
*/

/*
 * 連鎖代入
 *
 * 代入された値が代入の返り値になる
 * x = y = 4;
 * -> 変数yに4を代入した際の返り値4を、変数xに代入する
 * = 変数x、yの両方に4を代入する
*/
