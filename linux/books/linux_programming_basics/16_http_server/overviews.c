// 引用: ふつうのLinuxプログラミング
// 第15章 HTTPサーバを作る 1
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

// シグナル処理 -------------------------------------------
typedef void (*sighandler_t)(int);

// 全てのシグナルを管理する
static void install_signal_handlers(void);

// シグナルをハンドラに登録する
static void trap_signal(int sig, sighandler_t handler);

// ログを出力してexit()するハンド
static void signal_exit(int sig);

// サービス -----------------------------------------------

// リクエストを読み込み、レスポンスを出力する
static void service(FILE *in, FILE *out, char *docroot);

// リクエスト処理 -----------------------------------------

// リクエストを読み込み、HTTPRequest構造体を作る
static struct HTTPRequest* read_request(FILE *in);

// HTTPリクエストラインを解析してreqに書き込む
static void read_request_line(struct HTTPRequest *req, FILE *in);

// ヘッダフィールドを解析してreqに書き込む
static struct HTTPHeaderField* read_header_field(FILE *in);

// HTTPRequest構造体のために使用したメモリ領域を解放する
static void free_request(struct HTTPRequest *req);

// HTTPRequest構造体methodメンバの値を大文字に変換
static void upcase(char *str);

// リクエストのエンティティボディの長さを得る
static long content_length(struct HTTPRequest *req);

// ヘッダフィールドを名前で検索する
static char* lookup_header_field_value(struct HTTPRequest *req, char *name);

// レスポンス処理 -----------------------------------------

// FileInfo構造体を作成する
static struct FileInfo* get_fileinfo(char *docroot, char *path);

// ドキュメントルートとURLのパスからファイルシステム上のパスを生成
static char* build_fspath(char *docroot, char *path);

// FileInfo構造体のために使用したメモリ領域を解放する
static void free_fileinfo(struct FileInfo *info);

// reqに対するレスポンスをoutに書き込む
static void respond_to(struct HTTPRequest *req, FILE *out, char *docroot);

// GET/HEADリクエストに対する処理
static void do_file_response(struct HTTPRequest *req, FILE *out, char *docroot);

// 全てのレスポンスで共通のヘッダを出力
static void output_common_header_fields(struct HTTPRequest *req, FILE *out, char *status);

// 常に'text/plain'を返す
static char* guess_content_type(struct FileInfo *info);

// -------------------------------------------------------

static void method_not_allowed(struct HTTPRequest *req, FILE *out);

static void not_implemented(struct HTTPRequest *req, FILE *out);

static void not_found(struct HTTPRequest *req, FILE *out);

// メモリ管理 --------------------------------------------

// メモリの確保
static void* xmalloc(size_t sz);
// malloc()を使用する

// エラーハンドリングとログ出力 -------------------------

// 可変長引数を受け付け、フォーマットしてstderrに出力する
static void log_exit(char *fmt, ...);
// 可変長引数の利用
//   va_list ap;
//   va_start(ap, 可変長引数の一つ前の引数);
//   ~~ apを使用するコード ~~
//   va_end(ap):
