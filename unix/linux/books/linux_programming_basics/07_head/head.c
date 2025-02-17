// 引用: ふつうのLinuxプログラミング
// 第7章 headコマンドを作る 1

#define _GNU_SOURCE // getopt_long()のプロトタイプ宣言を読み込むために必要
#define DEFAULT_N_LINES 10

#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>

static void do_head(FILE *f, long nlines);

static struct option longopts[] = {           // option構造体の配列を宣言し、代入
  { "lines", required_argument, NULL, 'n' },  // 必ずパラメータをとる--lines(-n)オプションを定義
  { "help",  no_argument,       NULL, 'h' },  // パラメータをとらない--help(-h)オプションを定義
  { 0, 0, 0, 0 }                              // 配列の末尾を示す
};

int main(int argc, char *argv[])
{
  int opt;
  long nlines;

  while ((opt = getopt_long(argc, argv, "n:", longopts, NULL)) != -1) { // "n:"解析が必要なショートオプション
    switch (opt) {
      case 'n':
        nlines = atol(optarg); // atol() 整数表現を含む文字列から対応する整数型を取得する
        break;
      case 'h':
        fprintf(stdout, "Usage: %s [-n LINES] [FILE ...]\n", argv[0]);
        exit(0);
      case '?':
        fprintf(stderr, "Usage: %s [-n LINES] [FILE ...]\n", argv[0]);
        exit(1);
    }
  }

  if (optind == argc) { // optind 現在処理中のオプションのargvでのインデックス
    do_head(stdin, nlines);
  } else {
    int i;

    for (i = optind; i < argc; i++) {
      FILE *f;
      f = fopen(argv[i], "r");

      if (!f) { // f == NULL
        perror(argv[i]);
        exit(1);
      }

      do_head(f, nlines);
      fclose(f);
    }
  }

  exit(0);
}

static void do_head(FILE *f, long nlines) // *f 読み込むストリーム / nlines 表示する行数
{
  int c;

  if (nlines <= 0) {
    return;
  }

  while ((c = getc(f)) != EOF) { // 1バイト読み込んでcに格納
    if (putchar(c) < 0) { // stdoutmにcを書き込む
      exit(1);
    }

    if (c == '\n') { // 改行を見つけるたびに残行数を減らす
      nlines--;

      if(nlines == 0) {
        return;
      }
    }
  }
}

// コマンドラインオプションの指定
//   $ ls -a -s -k -> $ ls -ask / $ ls --all --size --kibibytes
//   $ head -n 5 -> $ head -n5 / $ head --line 5 / $ head --line=5
//
//   #include <unistd.h>
//
//   int main(int argc, char *argv[])
//   {
//     int opt;
//
//     while (opt = getopt(argc, argv, "af:") != -1) { -fはパラメータを取る
//       switch (opt) {
//         case 'a':
//           オプション-aの場合
//           break;
//         case 'f':
//           オプション-fの場合
//           break;
//         case '?':
//           不正なオプションを渡された場合
//           break;
//       }
//     }
//
//     ...
//   }
//
//   char *optarg 現在処理中のオプションのパラメータ
//   int optind   現在処理中のオプションのargvでのインデックス
//   int optopt   現在処理中のオプション文字
//
//   ロングオプションはgetopt_long()(#include <getopt.h>)で扱う
