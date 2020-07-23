/*
 * 引用: head first c
 * 第5章 構造体、共用体、ビットフィールド 8
*/

/*
 * booleanは1ビットによって表現できるため、
 * short型を使用するとメモリ空間が余る
 *
 * ビットフィールドによって
 * 個々のフィールドに格納するビット数を指定することができ、
 * 一連のビットフィールドを構造体にまとめると、
 * コンピュータはビットフィールドを圧縮して空間を節約する
 *
 *   typedef {
 *     unsigned int low_pass_vcf:1; フィールドが1ビットの格納領域
 *   } synth;
*/

#include <stdio.h>

/*
 * 水族館アンケート
 *   first_visit  初めての来館ですか？
 *   come_again   また来館したいと思いますか？
 *   fingers_lost ピラニア水槽で失った指の数(0 ~ 10)
 *   shark_attack サメの展示で子供を失いましたか？
 *   days_a_week  可能であれば一週間に何日来館したいですか？(0 ~ 7)
*/

typedef struct {
  unsigned int first_visit:1;  /* 1ビット 真偽値 */
  unsigned int come_again:1;   /* 1ビット 真偽値 */
  unsigned int fingers_lost:4; /* 4ビット 0 ~ 15までの数値(2進数で1111以内) */
  unsigned int shark_attack:1; /* 1ビット 真偽値 */
  unsigned int days_a_week:3;  /* 3ビット 0 ~ 7までの数値(2進数で111以内) */
} survey;

int main()
{
  return 0;
}
