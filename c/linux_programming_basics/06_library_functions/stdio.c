// 引用: ふつうのLinuxプログラミング
// 第6章 ストリームに関わるライブラリ関数 1
//
// standard I/O library 標準入出力ライブラリ
//   stdioを経由してread() / write()を実行する場合、
//   バッファリングによりある程度まとまった単位でデータを扱うことができる
//     <-> システムコールでread() / write()を実行する場合
//         バッファがないため、入出力分のデータを都度読み込み・書き込みする
//
//   write()時にバッファリングしないパターン
//     - ストリームの向こうに端末がある場合(バッファ単位でなく改行単位でwrite()を実行する)
//     - アンバッファモードの場合
//     - 標準エラー出力(stderr)を行う場合


//   FILE型
//     ストリームを表現する型
//     ファイルディスクリプタのラッパー
//     ファイルディスクリプタとstdioバッファの内部情報を含む
//
//   ファイルディスクリプタ
//     0 (STDIN_FINENO)  stdin変数  標準入力
//     1 (STDOUT_FINENO) stdout変数 標準出力
//     2 (STDERR_FINENO) stderr変数 標準エラー出力

#include <stdio.h>

FILE *fopen(const char *path, const char *mode);
// pathで示されたファイルにつながるストリームを作る
// -> ストリームを管理するFILEへのポインタを返す
//    エラーが発生した場合 NULL
//
//    mode ストリームの性質
//      r  O_RDONLY
//      w  O_WRONLY | O_CREAT | O_TRUNC
//      a  O_WRONLY | O_CREAT | O_APPEND
//      r+ O_RDWR
//      w+ O_RDWR | O_CREAT | O_TRUNC
//      a+ O_WRONLY | O_CREAT | O_APPEND

int fclose(FILE *stream);
// streamを閉じる
// -> 0を返す
//    エラーが発生した場合 EOF(-1)

int fileno(FILE *stream);
// streamがラップしているファイルディスクリプタを返す

FILE *fopen(int fd, const char *mode);
// ファイルディスクリプタfdをラップするFILE型の値を新しく作成する
// -> 作成したFILE型へのポインタを返す
//    エラーが発生した場合 NULL

// バッファリングの操作
int fflush(FILE *stream);
// streamがバッファリングしている内容を即座にwriteする(flush)
// -> 0を返す
//    エラーが発生した場合 EOF

// バイト単位の入出力API
int fgetc(FILE *stream); // 関数
int getc(FILE *stream);  // マクロ
// streamから1バイト読み込んで返す
// -> streamから1バイト読み込みintに変換したもの
//    ストリームが終了した場合 EOF(-1)
//    エラーが発生した場合     EOF(-1)

int fputc(int c, FILE *stream); // 関数
int putc(int c, FILE *stream);  // マクロ
// streamにバイトcを書き込む
// -> 書き込んだバイトを返す
//    エラーが発生した場合 EOF(-1)

int getchar(void);
// getc(stdin)と同じ

int putchar(int c);
// putc(int c, stdout)と同じ

int ungetc(int c, FILE *stream);
// バイトcをstreamのバッファに戻す

// 行単位の入出力API
char *fgets(char *buf, int size, FILE *stream);
// streamのストリームから一行読み込んでbufに格納する
// 最大size -1バイトまで読み込む
// sizeにはbufのサイズを指定する
// -> bufを返す
//    一文字も読まずにEOFに当たった場合 NULL
//
// 一行読んで止まったのかバッファいっぱいまで書き込んで止まったのか区別がつかない

int fputs(const char *buf, FILE *stream);
// bufの示す文字列をstreamのストリームに出力する
// -> 0を返す
//    ストリームにバイト列を書き終わった場合 EOF
//    エラーが発生した場合                   EOF

int puts(const char *buf);
// 文字列bufを標準出力に出力し、その後'\n'を出力する

int printf(const char *fmt, ...);
int fprintf(FILE *stream, const char *fmt, ...);
// fmtで指定した体裁に従い、後続の引数をフォーマットした文字列を出力する
//   printf  標準出力に出力
//   fprintf streamのストリームに出力

// 固定長の入出力 バッファを経由してデータを取り扱うことができる
size_t fread(void *buf, size_t size, size_t nmemb, FILE *stream);
// streamのストリームから最大size * nmembバイトのデータを読み込み、bufに書き込む
// -> nmembを返す
//    規定サイズ読み込み前にEOFに達した場合 nmembより小さい値
//    エラーが発生した場合                  nmembより小さい値
//
//    nmemb number of members

size_t fwrite(const void *buf, size_t size, size_t nmemb, FILE *stream);
// size * nmembバイトのデータをbufからstreamのストリームへ書き込む
// -> nmembを返す
//    エラーが発生した場合 nmembより小さい値

// ファイルオフセットの操作
int fseek(FILE *stream, long offset, int whence);
int fseeko(FILE *stream, off_t offset, int whence);
// streamのファイルオフセットをwhenceとoffsetで示される位置に移動させる
//
//   long  32ビットマシン向け
//   off_t 64ビットマシン向け(#define _FILE_OFFSET_BITS 64)

long ftell(FILE *stream);
off_t ftello(FILE *stream);
// streamのファイルオフセットを返す

void rewind(FILE *stream);
// streamのファイルオフセットをファイルの先頭に戻す

// EOFとエラー
int feof(FILE *stream);
// streamのストリームのEOFフラグを取得する
//   EOFフラグ
//     ストリーム作成時          false
//     読み込みがEOFに達した場合 true

int ferror(FILE *stream);
// streamのストリームのエラーフラグを取得する
//   エラーフラグ
//     ストリーム作成時     false
//     エラーが発生した場合 true

int clearerr(FILE *stream);
// streamのストリームのエラーフラグとEOFフラグをクリアする
