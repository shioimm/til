// 引用: ふつうのLinuxプログラミング
// 第15章 HTTPサーバを作る 2
// https://github.com/aamine/stdlinux2-source/blob/master/httpd.c

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
#include <stdarg.h> // 可変長引数
#include <ctype.h>
#include <signal.h>

#define SERVER_NAME "LittleHTTP"
#define SERVER_VERSION "1.0"
#define HTTP_MINOR_VERSION 0
#define BLOCK_BUF_SIZE 1024
#define LINE_BUF_SIZE 4096
#define MAX_REQUEST_BODY_LENGTH (1024 * 1024)

struct HTTPHeaderField {
  char *name;
  char *value;
  struct HTTPHeaderField *next;
};

struct HTTPRequest {
  int protocol_minor_version;
  char *method;
  char *path;
  struct HTTPHeaderField *header;
  char *body;
  long length;
};

struct FileInfo {
  char *path;
  long size;
  int ok;
};

typedef void (*sighandler_t)(int);
static void install_signal_handlers(void);
static void trap_signal(int sig, sighandler_t handler);
static void signal_exit(int sig);
static void service(FILE *in, FILE *out, char *docroot);
static struct HTTPRequest* read_request(FILE *in);
static void read_request_line(struct HTTPRequest *req, FILE *in);
static struct HTTPHeaderField* read_header_field(FILE *in);
static void upcase(char *str);
static void free_request(struct HTTPRequest *req);
static long content_length(struct HTTPRequest *req);
static char* lookup_header_field_value(struct HTTPRequest *req, char *name);
static void respond_to(struct HTTPRequest *req, FILE *out, char *docroot);
static void do_file_response(struct HTTPRequest *req, FILE *out, char *docroot);
static void method_not_allowed(struct HTTPRequest *req, FILE *out);
static void not_implemented(struct HTTPRequest *req, FILE *out);
static void not_found(struct HTTPRequest *req, FILE *out);
static void output_common_header_fields(struct HTTPRequest *req, FILE *out, char *status);
static struct FileInfo* get_fileinfo(char *docroot, char *path);
static char* build_fspath(char *docroot, char *path);
static void free_fileinfo(struct FileInfo *info);
static char* guess_content_type(struct FileInfo *info);
static void* xmalloc(size_t sz);
static void log_exit(char *fmt, ...);

int main(int argc, char *argv[])
{
  if (argc != 2) {
    fprintf(stderr, "Usage: %s <docroot>\n",, argv[0]);
    exit(1);
  }

  install_signal_handlers();
  service(stdin, stdout, argv[1]);
  exit(0);
}

// サーバー処理
static void service(FILE *in, FILE *out, char *docroot)
{
  struct HTTPRequest *req;

  req = read_request(in);
  respond_to(req, out, docroot);

  free_request(req);
}

// リクエストの読み込み
static struct HTTPRequest* read_request(FILE *in)
{
  struct HTTPRequest *req;
  struct HTTPHeaderField *h;

  req = xmalloc(sizeof(struct HTTPRequest));

  read_request_line(req, in); // リクエストラインの読み込み

  req->header = NULL;
  while (h = read_header_field(in)) { // リクエストヘッダの読み込み
    h->next = req->header;
    req->header = h;
  }

  req->length = content_length(req);
  if (req->length != 0) {
    if (req->length > MAX_REQUEST_BODY_LENGTH) {
      log_exit("request body too long");
    }
    req->body = xmalloc(req->length);
    if (fread(req->body, req->length, 1, in) < 1) {
      log_exit("failed to read request body");
    }
  } else {
    req->body = NULL;
  }

  return req;
}

// リクエストラインの読み込み
static void read_request_line(struct HTTPRequest *req, FILE *in)
{
  char buf[LINE_BUF_SIZE];
  char *path, *p;

  if (!fgets(buf, LINE_BUF_SIZE, in)) {
    log_exit("no request line");
  }

  // メソッドの取得
  p = strchr(buf, ' ');
  if (!p) {
    log_exit("parse error on request line (1): %s", buf);
  }
  *p++ = '\0';
  req->method = xmalloc(p - buf);
  strcpy(req->method, buf);
  upcase(req->method);

  // パスの取得
  path = p;
  p = strchr(path, ' ');
  if (!p) {
    log_exit("parse error on request line (2): %s", buf);
  }
  *p++ = '\0';
  req->method = xmalloc(p - path);
  strcpy(req->path, path);

  // プロトコルバージョンの取得
  if (strncasecmp(p, "HTTP/1.", strlen("HTTP/1.")) != 0) {
    log_exit("parse error on request line (3): %s", buf);
  }
  p += strlen("HTTP/1.");
  req->protocol_minor_version = atoi(p);
}

// リクエストヘッダの読み込み
static struct HTTPHeaderField* read_header_field(FILE *in)
{
  struct HTTPHeaderField *h;
  char buf[LINE_BUF_SIZE];
  char *p;

  if (!fgets(buf, LINE_BUF_SIZE, in)) {
    log_exit("failed to read request header field: %s", strerror(errno));
  }
  if ((buf[0] == '\n') || (strcmp(buf, "\r\n") == 0)) {
    return NULL;
  }

  p = strchr(buf, ':');
  if (!p) {
    log_exit("parse error on request header field: %s", buf)
  }
  *p++ = '\0';
  h = xmalloc(sizeof(struct HTTPHeaderField));
  h->name = xmalloc(p - buf);
  strcpy(h->name, buf);

  p += strspn(p, " \t");
  h->value = xmalloc(strlen(p) + 1);
  strcpy(h->value, p);

  return h;
}

// Content-Lengthの取得
static long content_length(struct HTTPRequest *req)
{
  char *val;
  long len;

  val = lookup_header_field_value(req, "Content-Length");
  if (!val) {
    return 0;
  }

  len = atol(val);
  if (len < 0){
    log_exit("negative Content-Length value");
  }
  return len;
}

// ヘッダの値を取得を取得
static char* lookup_header_field_value(struct HTTPRequest *req, char *name)
{
  struct HTTPHeaderField *h;

  for (h = req->header; h; h = h->next) {
    if (strcasecmp(h->name, name) == 0) {
      return h->value;
    }
  }
  return NULL;
}

// 小文字を大文字に変換
static void upcase(shar *str)
{
  char *p;

  for (p = str; *p; p++) {
    *p = (char)toupper((int)*p);
  }
}

// HTTPRequest構造体・HTTPHeaderField構造体のメモリ領域を解放
static void free_request(struct HTTPRequest *req)
{
  struct HTTPHeaderField *h, *head;

  head = req->header;

  while (head) {
    h = head;
    head = head->next;
    free(h->name);
    free(h->value);
    free(h);
  }

  free(req->method);
  free(req->path);
  free(req->body);
  free(req);
}

// FileInfo構造体の割り当て・初期化
static struct FileInfo* get_fileinfo(char *docroot, char *urlpath)
{
  struct FileInfo *info;
  struct stat st;

  info = xmalloc(sizeof(struct FileInfo));
  info->path = build_fspath(docroot, urlpath);
  info->ok = 0;

  if (lstat(info->path, &st) < 0) {
    return info;
  }
  if (!S_ISREG(st.st_mode)) {
    return info;
  }

  info->ok = 1;
  info->size = st.st_size;
  return info;
}

// ドキュメントルートとURLのパスからファイルシステム上のパスを生成
static char * build_fspath(char *docroot, char *urlpath)
{
  char *path;

  path = xmalloc(strlen(docroot) + 1 + strlen(urlpath) + 1);
  sprintf(path, "%s/%s", docroot, urlpath);
  return path;
}

// レスポンスを出力
static void respond_to(struct HTTPRequest *req, FILE *out, char *docroot)
{
  if (strcmp(req->method, "GET") == 0) {
    do_file_response(req, out, docroot);
  } else if (strcmp(req->method, "HEAD") == 0) {
    do_file_response(req, out, docroot);
  } else if (strcmp(req->method, "POST") == 0) {
    method_not_allowed(req, out);
  } else {
    not_implemented(req, out);
  }
}

// GETリクエストの処理
static void do_file_response(struct HTTPRequest *req, FILE *out, char *docroot)
{
  struct FileInfo *info;

  info = get_fileinfo(docroot, req->path);
  if (!info->ok) {
    free_fileinfo(info);
    not_found(req, out);
    return;
  }

  output_common_header_fields(req, out, "200 OK");
  fprintf(out, "Content-Length: %ld\r\n", info->size);
  fprintf(out, "Content-Type: %s\r\n", guess_content_type(info));
  fprintf(out, "\r\n");

  if (strcmp(req->method, "HEAD") != 0) {
    int fd;
    char buf[BLOCK_BUF_SIZE];
    ssize_t n;

    fd = open(info->path, O_RDONLY);
    if (fd < 0) {
      log_exit("failed to open %s: %s", info->path, strerror(errno));
    }
    for (;;) {
      n = read(fd, buf, BLOCK_BUF_SIZE);
      if (n < 0) {
        log_exit("failed to read %s: %s", info->path, strerror(errno));
      }
      if (n == 0) {
        break;
      }
      if (fwrite(buf, 1, n, out) < n) {
        log_exit("failed to write to socket");
      }
      close(fd);
    }
  }

  fflush(out);
  free_fileinfo(info);
}

// Content-Typeは常に"text/plain"を返す
static char* guess_content_type(struct FileInfo *info)
{
  return "text/plain"; // FIXME
}

// 共通のレスポンスヘッダを生成
#define TIME_BUF_SIZE 64

static void output_common_header_fields(struct HTTPRequest *req, FILE *out, char *status)
{
  time_t t;
  struct tm *tm;
  char buf[TIME_BUF_SIZE];

  t = time(NULL);
  tm = gmtime(&:t);
  if (!tm) {
    log_exit("gmtime() failed: %s", strerror(errno));
  }
  strftime(buf, TIME_BUF_SIZE, "%a, %d %b %Y %H:%M:%S GMT", tm);
  fprintf(out, "HTTP/1.%d %s\r\n", HTTP_MINOR_VERSION, status);
  fprintf(out, "Date: %s\r\n", buf);
  fprintf(out, "Server: %s/%s\r\n", SERVER_NAME, SERVER_VERSION);
  fprintf(out, "Connection: close\r\n");
}

// FileInfo構造体のメモリ領域を解放
static void free_fileinfo(struct FileInfo *info)
{
  free(info->path);
  free(info);
}

// シグナル管理
static void install_signal_handlers(void)
{
  trap_signal(SIGPIPE, signal_exit);
}

static void trap_signal(int sig, sighandler_t handler)
{
  struct sigaction act;

  act.sa_handler = handler;
  sigemptyset(&act.sa_mask);
  act.sa_flags = SA_RESTART;

  if (sigaction(sig, &act, NULL) < 0) {
    log_exit("sigaction() failed: %s", strerror(errno))
  }
}

static void signal_exit(int sig)
{
  log_exit("exit by signal %d", dig);
}

// メモリの確保
static void* xmalloc(size_t sz)
{
  void *p;

  p = malloc(sz);
  if (!p) {
    log_exit("failed to allocate memory");
  }
  return p;
}

// 可変長引数を受け付け、フォーマットしてstderrに出力する
static void log_exit(char *fmt, ...)
{
  va_list ap;

  va_start(ap, fmt);
  vfprintf(stderr, fmt, ap); // 引数にapを渡すfprintf()
  fputc('\n', stderr);
  va_end(ap);

  exit(1);
}
