/*
 * 引用: head first c
 * 第3章 小さなツールの作成 1
*/

#include <stdio.h>

/*
 * 要件
 *   各行の緯度・経度・その他のデータを読み込み、
 *   JSONにフォーマットして出力する
*/

int main()
{
  float latitude;
  float longitude;
  char info[80];
  int started = 0; /* false */

  puts("data=[");

  /*
   * 各変数のアドレスに入力データを格納し、入力データ数を返す
   * scanf()には入力データのポインタを渡す必要がある
  */
  while (scanf("%f, %f, %79[^\n]", &latitude, &longitude, info) == 3) {
    if (started) {
      printf(", \n"); /* 前の行をすでに出力している場合はカンマを出力 */
    } else {
      started = 1; /* true */
    }

    /* 不正な値が入力された場合、標準エラーデータストリームへ出力 */
    if ((latitude < -90.0) || (latitude > 90.0)) {
      fprintf(stderr, "Invalid latitude: %f\n", latitude);
      return 2; /* エラーコードによってプログラムを終了 */
    }

    /* 不正な値が入力された場合、標準エラーデータストリームへ出力 */
    if ((longitude < -180.0) || (longitude > 180.0)) {
      fprintf(stderr, "Invalid longitude: %f\n", longitude);
      return 2; /* エラーコードによってプログラムを終了 */
    }

    /*
     * 変数に格納された値を標準出力データストリームへ出力
     * (データのアドレスではなく値を出力するため、&をつける必要はない)
    */
    fprintf(stdout, "{latitude: %f, longitude: %f, info: '%s'}", latitude, longitude, info);
  }

  puts("\n]");

  return 0;
}
/*
 * fprintf()はデータをデータストリーム(stdout, stderr)に送る
 *   fprintf(stdout, ...) == printf(...)
 * fscanf()はデータをデータストリーム(stdin)から取り込む
 *   fscanf(stdin, ...) == scanf(...)
*/

/*
 * 入出力先を指定せずに実行
 * キーボードから入力を受け付け、ターミナルに出力
 * ./geo2json
 *
 * 入力元ファイルを指定する
 * ./geo2json < gpsdata.csv
 *
 * 出力先ファイルを指定する
 * ./geo2json > output.json
 *
 * 入出力先ファイルを同時に指定する
 * ./geo2json < gpsdata.csv > output.json
 *
 * 入出力先ファイルを同時に指定し、エラーは別のファイルに出力する
 * ./geo2json < gpsdata.csv > output.json 2> error.txt
*/
