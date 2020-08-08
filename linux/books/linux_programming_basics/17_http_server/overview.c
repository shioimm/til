// 引用: ふつうのLinuxプログラミング
// 第17章 HTTPサーバを本格化する 1
// https://github.com/aamine/stdlinux2-source/blob/master/httpd2.c

// 必要な機能:
//   サービス
//     static void service(FILE *in, FILE *out, char *docroot);
//   リクエスト処理
//     static struct HTTPRequest* read_request(FILE *in);
//       static void read_request_line(struct HTTPRequest *req, FILE *in);
//       static struct HTTPHeaderField* read_header_field(FILE *in);
//       static void free_request(struct HTTPRequest *req);
//   レスポンス処理
//     static struct FileInfo* get_fileinfo(char *docroot, char *path);
//     static char* build_fspath(char *docroot, char *path);
//     static void free_fileinfo(struct FileInfo *info);
//     static void respond_to(struct HTTPRequest *req, FILE *out, char *docroot);
//       static void do_file_response(struct HTTPRequest *req, FILE *out, char *docroot);
//       static void method_not_allowed(struct HTTPRequest *req, FILE *out);
//       static void not_implemented(struct HTTPRequest *req, FILE *out);
//       static void not_found(struct HTTPRequest *req, FILE *out);
//   シグナル処理
//     static void install_signal_handlers(void);
//       static void trap_signal(int sig, sighandler_t handler);
//         static void signal_exit(int sig);
//   エラーハンドリング
//     static void log_exit(char *fmt, ...);
//   ログ出力
//     static void log_exit(char *fmt, ...);

// TODO:
//   ソケット接続
//     サーバーが稼働するホストのアドレス構造体を元にsocket() -> bind() -> listen() -> accept()
//     bind/listenしたソケットでaccept -> fork -> 親のソケットをclose -> レスポンスを返し子のソケットをclose
//       親をwaitさせないようにすることによって子のゾンビ化を防ぐ
//   デーモン化
//     ルートディレクトリにchdir() -> stdin/outを/dev/nullにつなぐ -> 制御端末を切り離す
//     #include <unistd.h>
//     int daemon(int nochdir, int noclose);
//   syslogを使ったロギング
//     #include <syslog.h>
//     void syslog(int priority, const char *fmt, ...)
//   chroot()・クレデンシャル変更
//     ドキュメントツリーの外のファイルが見えないようにルートを変更
//     #include <unistd.h>
//     int chroot(const char *path);
//   コマンドラインオプション解析
//     ロングオプションのみを扱う

// ソケット接続 -----------------------------------------
static int listen_socket(char *port); // socket()、bind()、listen()を行う

static void server_main(int server, char *docroot); // accept()、fork、サービスの実行を行う

//// 並行処理 ---------------------------------------------
static void detach_children(void); // 親プロセス()がwaitしないようにする
// ------------------------------------------------------

// デーモン化 -------------------------------------------
static void become_daemon(void); // ルートディレクトリへchdir()、stdin/outをdev/nullへつなぎ直し、制御端末の切り離し
// ------------------------------------------------------

// ログ出力 ---------------------------------------------
static void log_exit(const char *fmt, ...); // sylog()でログ出力
// ------------------------------------------------------

// chroot() ---------------------------------------------
static void setup_environment(char *root, char *user, char *group); // ルートディレクトリの変更
// ------------------------------------------------------
