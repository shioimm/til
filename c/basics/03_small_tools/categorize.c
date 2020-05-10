/*
 * 引用: head first c
 * 第3章 小さなツールの作成
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 * ファイルの実行中に新しいデータストリームを作成する
 *   FILE *in_file = fopen("input.txt", "r");   -> 読み込みモード
 *   FILE *out_file = fopen("output.txt", "w"); -> 書き込みモード
 *   ファイルはポインタで表される
 *
 * データストリームから入力する
 *   fscanf(in_file, "%79[^\n]\n", sentence);
 *
 * データストリームに出力する
 *   fprintf(out_file, "%sと%sを一緒に着ないでください", "red", "green");
 *
 * データストリームを閉じる
 *   fclose(in_file);
 *   fclose(out_file);
*/

int main(int argc, char *argv[])
{
  char line[80];

  if (argc != 6) {
    fprintf(stderr, "5つの引数を指定してください\n");
    return 1; /* エラーコード1によって終了 */
  }

  FILE *in = fopen("spooky.csv", "r");
  FILE *file1 = fopen(argv[2], "w");
  FILE *file2 = fopen(argv[4], "w");
  FILE *file3 = fopen(argv[5], "w");

  while (fscanf(in, "%79[^\n]\n", line) == 1) {
    if (strstr(line, argv[1])) {
      fprintf(file1, "%s\n", line);
    } else if (strstr(line, argv[3])) {
      fprintf(file2, "%s\n", line);
    } else {
      fprintf(file3, "%s\n", line);
    }
  }

  fclose(file1);
  fclose(file2);
  fclose(file3);

  return 0;
}

/*
 * 1プロセスが持てるデータストリームは通常最大256個
*/

/*
 * 実行時にコマンドライン引数を渡す
 *   ./categorize mermaid mermaid.csv Elvis elvis.csv the_rest.csv
 *   コマンド 検索文字列 出力先 検索文字列 出力先 その他の語の出力先
 *   argv[0] argv[1] argv[2] argv[3] argv[4] argv[5]
 *   argv[0]は必ず実行コマンドになる
*/
