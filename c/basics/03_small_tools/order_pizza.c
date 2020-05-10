/*
 * 引用: head first c
 * 第3章 小さなツールの作成
*/

/*
 * getopt()関数
 *   コマンドラインオプションを利用する
 * optarg変数
 *   オプション引数
 * optind変数
 *   次に処理されるオプションのインデックス
*/

#include <stdio.h>
#include <unistd.h> /* getoptライブラリの読み込み */

int main(int argc, char *argv[])
{
  char *delivery = "";
  int thick = 0;
  int count = 0;
  char ch;

  while ((ch = getopt(argc, argv, "d:t")) != EOF) { /* 引数が必要なオプションに:をつける */
    switch (ch) { /* オプションの確認 */
    case 'd':
      delivery = optarg; /* コマンドライン引数を渡す */
      break;
    case 't':
      thick = 1; /* true */
      break;
    default:
      fprintf(stderr, "Unknown option: %s\n", optarg);
      return 1;
    }
  }

  argc -= optind; /* 読み込んだオプションをスキップするようにする */
  argv += optind; /* 読み込んだオプションをスキップするようにする */

  if (thick) {
    puts("Thick crust");
  }

  if (delivery[0]) {
    printf("To be delivered %s.\n", delivery);
  }

  puts("Ingredients:");

  /*
   * オプションを処理した後、最初のトッピングはargc[0]
   * argc未満の間はループを続ける
  */
  for (count = 0; count < argc; count++) {
    puts(argv[count]);
  }

  return 0;
}

/*
 * $ gcc ./order_pizza.c -o .order_pizza && ./order_pizza -d now -t Anchovies Pineapple
 *   Thick crust
 *   To be delivered now.
 *   Ingredients:
 *   Anchovies
 *   Pineapple
 *
 * $ gcc ./order_pizza.c -o .order_pizza && ./order_pizza -d
 *   c/basics/03_small_tools/order_pizza: option requires an argument -- d
 *   Unknown option: (null)
*/

/*
 * コマンドラインに - を渡すとオプションとして扱われる
 *   主要な引数の前に渡す必要がある
 *   -xなど負の数を渡す場合、 -- を明示的に渡す ex. ./order_pizza -d -- -x
 *   (-- が渡されるとオプションの読み込みを中止する)
 * */
