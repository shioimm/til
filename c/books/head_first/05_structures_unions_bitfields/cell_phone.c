/*
 * 引用: head first c
 * 第5章 構造体、共用体、ビットフィールド 2
*/

#include <stdio.h>

typedef struct cell_phone {
  int cell_no;
  const char *wallpaper;
  float minutes_of_charge;
} phone; /* cell_phoneのエイリアスとしてphoneを定義 */

/*
 * 構造体名を省略しても良い(匿名struct)
 * typedef struct {
 *   int cell_no;
 *   const char *wallpaper;
 *   float minutes_of_charge;
 * } phone;
*/


int main()
{
  phone p = { 55557879, "sinatra.png", 1.35 }; /* エイリアスで型を指定 */

  return 0;
}
