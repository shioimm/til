/*
 * 引用: head first c
 * 第3章 小さなツールの作成
*/

#include <stdio.h>

/*
 * 要件
 *   各行の緯度・経度・その他のデータを読み込み、
 *   緯度が26 ~ 34かつ経度が-64 ~ -76の行を出力する
*/

int main()
{
  float latitude;
  float longitude;
  char info[80];

  while (scanf("%f, %f, %79[^\n]", &latitude, &longitude, info) == 3) {
    if ((latitude > 26) && (latitude <= 34)) {
      if ((longitude > -76) && (longitude < -64)) {
        printf("%f, %f, %s\n", latitude, longitude, info);
      }
    }
  }

  return 0;
}

/*
 * 複数のプログラムを組み合わせて実行する
 * (bermudaの出力をパイプでgeo2jsonにつなぐ)
 * (./bermuda | ./geo2json) < gpsdata.csv
 * プログラムは同時に動作し、bermudaが出力を作成するとgeo2jsonで出力が使用できるようになる
 *
 * パイプライン
 *   連結された一連のプロセス
 *   < はパイプラインの最初のプロセスへ標準入力を実行する
 *   > はパイプラインの最後のプロセスからの標準出力を取得する
*/
