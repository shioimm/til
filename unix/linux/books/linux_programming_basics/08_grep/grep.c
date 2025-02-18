// 引用: ふつうのLinuxプログラミング
// 第8章 grepコマンドを作る 1

// while (バッファに一行読み込む) {
//   if (バッファの中身が正規表現に適合する) {
//     バッファの中身を出力
//   }
// }
//
// char *fgets(char *buf, int size, FILE *stream);
//   streamのストリームから一行読み込んでbufに格納する

// 正規表現
//
// #include <sys/types.h>
// #include <regex.h>
//
// int regcomp(regex_t *reg, const char *pattern, int flags);
//   patternをregex_t型のデータに変換する
//   -> 0 / エラーコードを返す
//
// void regfree(regex_t *reg);
//   regcomp()で独自にregex_t *reg内部へ確保されたメモリ領域を解放する
//
// int regexec(const regex_t *reg, conat char *string, size_t nmatch, regmatch_t pmatch[], int flags);
//   正規表現regを文字列stringと照合する
//   -> 0 / REG_NOMATCHを返す
//
// size_t regerror(int errcode, const regex_t *reg, char *msgbuf, size_t msgbuf_size);
//   REG_NOMATCHのエラーコードを返す

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <regex.h>

static void do_grep(regex_t *pat, FILE *src);

int main(int argc, char *argv[])
{
  regex_t pat;
  int err;
  int i;

  if (argc < 2) {
    fputs("no pattern\n", stderr);
    exit(1);
  }

  err = regcomp(&pat, argv[1], REG_EXTENDED | REG_NOSUB | REG_NEWLINE); // パターン文字列をregex_tに変換
  // REG_EXTENDED POSIX拡張正規表現を使用
  // REG_NOSUB    マッチした位置を報告しない
  // REG_NEWLINE  改行文字を普通の文字として扱わない

  if (err != 0) {
    char buf[1024];

    regerror(err, &pat, buf, sizeof buf);
    puts(buf);
    exit(1);
  }

  if (argc == 2) {
    do_grep(&pat, stdin);
  } else {
    for (i = 2; i < argc; i++) {
      FILE *f; // 入力ストリームを用意
      f = fopen(argv[i], "r"); // ファイルを開き、入力ストリームに関連付ける

      if (!f) {
        perror(argv[i]);
        exit(1);
      }

      do_grep(&pat, f);
      fclose(f);
    }
  }

  regfree(&pat);
  exit(0);
}

static void do_grep(regex_t *pat, FILE *src) // 正規表現パターンと入力ストリームを受け取る
{
  char buf[4096];

  // 入力ストリームから一行読み込み、正規表現パターンに合致する場合は出力
  while (fgets(buf, sizeof buf, src)) {
    if (regexec(pat, buf, 0, NULL, 0) == 0) {
      fputs(buf, stdout);
    }
  }
}
