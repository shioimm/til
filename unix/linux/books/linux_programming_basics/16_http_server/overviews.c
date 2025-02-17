// 引用: ふつうのLinuxプログラミング
// 第16章 HTTPサーバを作る 1
// https://github.com/aamine/stdlinux2-source/blob/master/httpd.c

// HTTPとファイルシステムの比較
//   GET  <-> cat(1)
//   HEAD <-> stat(2)
//   POST <-> コマンドの実行
//
//   URLのパス <-> ファイルシステムのパス
//     ドキュメントツリー - 公開されているドキュメントのディレクトリ群
//     ドキュメントルート - ドキュメントツリーのルートディレクトリ

// HTTPサーバの設計
//   HTTPリクエストをドキュメントルート以下のファイルにマップし、
//   レスポンスとして送り返す
//
//   エラーハンドリング -> exit()
//   対応バージョン     -> HTTP/1.0
//   パラメータ         -> 設定ファイルを使用せずコマンドライン引数で渡す

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <time.h>
#include <stdarg.h>
#include <ctype.h>
#include <signal.h>

// サービス -----------------------------------------------
static void service(FILE *in, FILE *out, char *docroot); // リクエストを読み込み、レスポンスを出力する
// --------------------------------------------------------

// リクエスト処理 -----------------------------------------
static struct HTTPRequest* read_request(FILE *in); // リクエストを読み込む・HTTPRequest構造体を作る

static void read_request_line(struct HTTPRequest *req, FILE *in); // リクエストラインを解析してHTTPRequestに適用する

static struct HTTPHeaderField* read_header_field(FILE *in); // ヘッダを解析してHTTPHeaderFieldに適用する

static void free_request(struct HTTPRequest *req); // HTTPRequest構造体のために使用したメモリ領域を解放する

//// ヘルパー ---------------------------------------------
static void upcase(char *str); // HTTPRequest構造体methodメンバの値を大文字に変換

static long content_length(struct HTTPRequest *req); // リクエストのエンティティボディの長さを得る

static char* lookup_header_field_value(struct HTTPRequest *req, char *name); // ヘッダの値を返す
// --------------------------------------------------------

// レスポンス処理 -----------------------------------------
static struct FileInfo* get_fileinfo(char *docroot, char *path); // FileInfo構造体を作成する

static char* build_fspath(char *docroot, char *path); // ドキュメントルートとパスからファイルシステム上のパスを生成

static void free_fileinfo(struct FileInfo *info); // FileInfo構造体のために使用したメモリ領域を解放する

static void respond_to(struct HTTPRequest *req, FILE *out, char *docroot); // reqに対するレスポンスをoutに書き込む

//// サーバー処理 -----------------------------------------
static void do_file_response(struct HTTPRequest *req, FILE *out, char *docroot); // GET/HEADリクエストに対する処理

static void method_not_allowed(struct HTTPRequest *req, FILE *out);

static void not_implemented(struct HTTPRequest *req, FILE *out);

static void not_found(struct HTTPRequest *req, FILE *out);

//// ヘルパー ---------------------------------------------
static void output_common_header_fields(struct HTTPRequest *req, FILE *out, char *status); // 共通のヘッダを出力

static char* guess_content_type(struct FileInfo *info); // 常に'text/plain'を返す
// -------------------------------------------------------

// シグナル処理 -------------------------------------------
typedef void (*sighandler_t)(int);

static void install_signal_handlers(void); // 全てのシグナルハンドリング設定を読み込む

static void trap_signal(int sig, sighandler_t handler); // シグナルをハンドラに登録する

static void signal_exit(int sig); // ハンドラ: ログを出力してexit()する
// --------------------------------------------------------

//// メモリ管理 ------------------------------------------
static void* xmalloc(size_t sz);// メモリの確保
// -------------------------------------------------------

//// エラーハンドリングとログ出力 ------------------------
static void log_exit(char *fmt, ...); // 可変長引数を受け付け、フォーマットしてstderrに出力する
// 可変長引数の利用
//   va_list ap;
//   va_start(ap, 可変長引数の一つ前の引数);
//   ~~ apを使用するコード ~~
//   va_end(ap):
