// 引用: ふつうのLinuxプログラミング
// 第7章 headコマンドを作る 2

// gdb デバッガ
//   [1] プログラムをビルド
//     $ gcc -Wall -g -o head head.c
//   [2] gdbを起動
//     $ gdb ./head
//   [3] '-n 5'オプションによってプログラムを試行し、問題が発生した箇所を表示
//     (gdb) run -n 5
//   [4] backtraceを表示
//     (gdb) backtrace
//   [5] main()に移動(backtraceの#n行を指定)
//     (gdb) frame 3
//   [6] frameよりも広い範囲を表示
//     (gdb) list
//   [7] 調べたい情報を出力
//     (gdb) print optarg
//   [8] gdbを終了
//     (gdb) quit

#define _GNU_SOURCE
#define DEFAULT_N_LINES 10

#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>

static void do_head(FILE *f, long nlines);

static struct option longopts[] = {
  { "lines", required_argument, NULL, 'n' },
  { "help",  no_argument,       NULL, 'h' },
  { 0, 0, 0, 0 }
};

int main(int argc, char *argv[])
{
  int opt;
  long nlines;

  while ((opt = getopt_long(argc, argv, "n", longopts, NULL)) != -1) {
    switch (opt) {
      case 'n':
        nlines = atol(optarg);
        break;
      case 'h':
        fprintf(stdout, "Usage: %s [-n LINES] [FILE ...]\n", argv[0]);
        exit(0);
      case '?':
        fprintf(stderr, "Usage: %s [-n LINES] [FILE ...]\n", argv[0]);
        exit(1);
    }
  }

  if (optind == argc) {
    do_head(stdin, nlines);
  } else {
    int i;

    for (i = optind; i < argc; i++) {
      FILE *f;
      f = fopen(argv[i], "r");

      if (!f) {
        perror(argv[i]);
        exit(1);
      }

      do_head(f, nlines);
      fclose(f);
    }
  }

  exit(0);
}

static void do_head(FILE *f, long nlines)
{
  int c;

  if (nlines <= 0) {
    return;
  }

  while ((c = getc(f)) != EOF) {
    if (putchar(c) < 0) {
      exit(1);
    }

    if (c == '\n') {
      nlines--;

      if(nlines == 0) {
        return;
      }
    }
  }
}
