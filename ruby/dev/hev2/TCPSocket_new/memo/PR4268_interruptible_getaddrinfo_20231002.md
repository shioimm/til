# 中断可能な`rsock_getaddrinfo`の実装

```c
// ext/socket/raddrinfo.c
struct getaddrinfo_arg
{
  const char *node;
  const char *service;
  const struct addrinfo *hints;
  struct addrinfo **res;
  // 以下追加
  VALUE queue;
  int ret;
};
```

```c
// ext/socket/raddrinfo.c
// 当時の実装。ここはこのPRでは変更なし。

struct rb_addrinfo*
rsock_getaddrinfo(VALUE host, VALUE port, struct addrinfo *hints, int socktype_hack)
{
  struct rb_addrinfo* res = NULL;
  char *hostp, *portp;
  int error;
  char hbuf[NI_MAXHOST], pbuf[NI_MAXSERV];
  int additional_flags = 0;

  hostp = host_str(host, hbuf, sizeof(hbuf), &additional_flags);
  portp = port_str(port, pbuf, sizeof(pbuf), &additional_flags);

  if (socktype_hack && hints->ai_socktype == 0 && str_is_number(portp)) {
    hints->ai_socktype = SOCK_DGRAM;
  }
  hints->ai_flags |= additional_flags;

  error = rb_getaddrinfo(hostp, portp, hints, &res);

  if (error) {
    if (hostp && hostp[strlen(hostp)-1] == '\n') {
      rb_raise(rb_eSocket, "newline at the end of hostname");
    }
    rsock_raise_socket_error("getaddrinfo", error);
  }

  return res;
}
```

```c
// ext/socket/raddrinfo.c
// TypedData_Make_Structの第三引数で使用するデータと関数群

// (internal/core/rtypeddata.h)
//   構造体に必要な情報を保持する構造体
//   typedef struct rb_data_type_struct rb_data_type_t;
//
//   struct rb_data_type_struct {
//     const char *wrap_struct_name; // この構造体を識別する名前
//     struct {
//       void (*dmark)(void*); // ガベージコレクタがオブジェクトへの参照をマークするときに用いる関数
//       void (*dfree)(void*); // この構造体がもう不要になった時にガベージコレクタから呼ばれる関数
//       size_t (*dsize)(const void *); // 構造体が消費しているメモリのバイト数を返す関数
//       void *reserved[2];             // 0埋めが必要
//     } function;
//     const rb_data_type_t *parent;    // 0埋めが必要
//     void *data;  // ユーザー定義の任意の値
//     VALUE flags; // フラグ
//   };

static const rb_data_type_t getaddrinfo_arg_data_type = {
  "socket/getaddrinfo_arg",
  {
    getaddrinfo_arg_mark,
    getaddrinfo_arg_free,
    getaddrinfo_arg_memsize,
  },
};

static void
getaddrinfo_arg_mark(void *ptr)
{
  struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)ptr;
  rb_gc_mark(arg->queue);
}

static void
getaddrinfo_arg_free(void *ptr)
{
  struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)ptr;
  ruby_xfree(arg);
}

static size_t
getaddrinfo_arg_memsize(const void *ptr)
{
  return sizeof(struct getaddrinfo_arg);
}
```

```c
// ext/socket/raddrinfo.c

VALUE getaddrinfo_queue; // SizedQueueオブジェクト

void
rsock_init_addrinfo(void)
{
  // ...
  getaddrinfo_queue = rb_szqueue_new(20); // same as maximal number of threads in getaddrinfo_a(3)
  rb_gc_register_mark_object(getaddrinfo_queue);
  // ...
}

int
rb_getaddrinfo(
  const char *node,
  const char *service,
  const struct addrinfo *hints,
  struct rb_addrinfo **res
) {
  struct addrinfo *ai;
  int ret;
  int allocated_by_malloc = 0;
  ret = numeric_getaddrinfo(node, service, hints, &ai);

  if (ret == 0) {
    allocated_by_malloc = 1;
  } else {
#ifdef GETADDRINFO_EMU
    ret = getaddrinfo(node, service, hints, &ai);
#else
    // 以下削除
    //   struct getaddrinfo_arg arg;
    //   MEMZERO(&arg, struct getaddrinfo_arg, 1);
    //   arg.node = node;
    //   arg.service = service;
    //   arg.hints = hints;
    //   arg.res = &ai;
    //   ret = (int)(VALUE)rb_thread_call_without_gvl(nogvl_getaddrinfo, &arg, RUBY_UBF_IO, 0);

    // 以下追加
    struct getaddrinfo_arg *ptr;

    // (internal/core/rtypeddata.h)
    // TypedData_Make_Struct - 構造体へのポインタptrの割り当てと対応するRubyオブジェクトを生成する
    // 生成されたオブジェクトのVALUE値を返す
    // klassが0の場合はどうなるんだろう...?
    VALUE arg_wrapper = TypedData_Make_Struct(
      0,                          // @param klass     オブジェクトのRubyレベルのクラス
      struct getaddrinfo_arg,     // @param type      C構造体の型名
      &getaddrinfo_arg_data_type, // @param data_type typeを記述するデータ型
      ptr                         // @param sval      作成されたC構造体の変数名
    );

    MEMZERO(ptr, struct getaddrinfo_arg, 1);

    ptr->node = node;       // ホスト名 (char*)
    ptr->service = service; // ポート番号 (char*)
    ptr->hints = hints;
    ptr->res = &ai;
    ptr->queue = rb_queue_new(); // Queueオブジェクトを作って格納

    // getaddrinfo_queue (SizedQueue) にarg_wrapperオブジェクトをpush
    // この時点では VALUE rb_szqueue_push(int argc, VALUE *argv, VALUE self) というインターフェースだった
    rb_szqueue_push(1, &arg_wrapper, getaddrinfo_queue);

    // getaddrinfo_queue待ちのスレッド数が0の場合
    if (NUM2INT(rb_szqueue_num_waiting(getaddrinfo_queue)) == 0) {
      // 新しいスレッドを生成し、start_getaddrinfo()を実行
      rb_thread_create(start_getaddrinfo, NULL);
    }

    // QueueオブジェクトからFixnumとしてretを取り出す (取り出せるようになるまで待機)
    // この時点では VALUE rb_queue_pop(int argc, VALUE *argv, VALUE self) というインターフェースだった
    ret = FIX2INT(rb_queue_pop(0, NULL, ptr->queue));
#endif
  // 以下変更なし
  }

  if (ret == 0) {
    *res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
    (*res)->allocated_by_malloc = allocated_by_malloc;
    (*res)->ai = ai;
  }

  return ret;
}
```

```c
// ext/socket/raddrinfo.c

static VALUE
start_getaddrinfo(void *unused)
{
  struct getaddrinfo_arg *ptr;
  VALUE arg_wrapper;

  // getaddrinfo_queue待ちのスレッド数が0の場合
  while (NUM2INT(rb_szqueue_num_waiting(getaddrinfo_queue)) == 0) {
    // getaddrinfo_queue から arg_wrapper を取り出す
    arg_wrapper = rb_szqueue_pop(0, NULL, getaddrinfo_queue);

    if (NIL_P(arg_wrapper)) { break; }

    // arg_wrapperオブジェクトから構造体へのポインタを復元し、ptrへ格納
    TypedData_Get_Struct(arg_wrapper, struct getaddrinfo_arg, &getaddrinfo_arg_data_type, ptr);

    // ptr->retにnogvl_getaddrinfo()の返り値として実行結果を格納
    // 成功した時点でptr->res (ai) にaddrinfoを格納している
    ptr->ret = (int)(VALUE)rb_thread_call_without_gvl(nogvl_getaddrinfo, ptr, RUBY_UBF_IO, 0);

    // rb_protect - push_getaddrinfo_result((VALUE)ptr) を実行し、その戻り値を返す
    rb_protect(push_getaddrinfo_result, (VALUE)ptr, NULL);
  }

  return Qnil;
}
```


```c
// ext/socket/raddrinfo.c

static VALUE
push_getaddrinfo_result(VALUE arg)
{
  struct getaddrinfo_arg *ptr = (struct getaddrinfo_arg *)arg;
  // ptr->queue に ptr->ret をpush
  return rb_queue_push(ptr->queue, INT2FIX(ptr->ret));
}
```

```c
// include/ruby/internal/intern/thread.h

VALUE rb_queue_new(void);
VALUE rb_queue_push(VALUE self, VALUE obj);
VALUE rb_queue_pop(int argc, VALUE *argv, VALUE self);

VALUE rb_szqueue_new(long max);
VALUE rb_szqueue_push(int argc, VALUE *argv, VALUE self);
VALUE rb_szqueue_pop(int argc, VALUE *argv, VALUE self);
VALUE rb_szqueue_num_waiting(VALUE self);
```

```c
// thread_sync.c

// Queueを作ってるんだと思われる
VALUE
rb_queue_new(void)
{
  VALUE self = queue_alloc(rb_cQueue);
  struct rb_queue *q = queue_ptr(self);
  RB_OBJ_WRITE(self, &q->que, ary_buf_new());
  list_head_init(queue_waitq(q));
  return self;
}

// SizedQueueを作ってるんだと思われる
VALUE
rb_szqueue_new(long max)
{
  VALUE self = szqueue_alloc(rb_cSizedQueue);
  struct rb_szqueue *sq = szqueue_ptr(self);

  if (max <= 0) {
    rb_raise(rb_eArgError, "queue size must be positive");
  }

  RB_OBJ_WRITE(self, &sq->q.que, ary_buf_new());
  list_head_init(szqueue_waitq(sq));
  list_head_init(szqueue_pushq(sq));
  sq->max = max;

  return self;
}

// このほかに
// rb_queue_push
// rb_queue_pop
// rb_szqueue_push
// rb_szqueue_pop
// rb_szqueue_num_waiting
// からstaticを外している
```

## TL;DR
- `getaddrinfo(3)`の結果のaddrinfoを格納するためのQueueを用意
- `getaddrinfo(3)`を呼び出す際の引数を格納するためのSizedQueueを用意
  - SizedQueueにはVALUEしかpushできないので、この引数は`TypedData_Make_Struct`を用いてVALUEにする
  - そのためにGC系の処理が必要
- SizedQueue待ちのスレッド数が0の場合は新しいスレッドを生成して`start_getaddrinfo()`を実行
  - メインスレッドはQueueに値がpushされるまで待機
  - スレッドの中でSizedQueueから引数オブジェクトを取り出し、`nogvl_getaddrinfo()`を実行して結果をQueueにpush

## 所感
- getaddrinfo(3)をスレッドに包むだけで中断可能になるのかなあ
- Queueを使っているので明示的にMutexが不要になるのは良さそう
- addrinfoを得た後でQueueとSizedQueueを閉じてない気がする
- 作ったスレッドはjoinしなくていいんだろうか
- この変更を行った上でHappy Eyeballsの仕様を満たすように`init_inetsock_internal_happy()` (PR4262) に
  名前解決の処理を入れる必要がある。完成系はどんな感じになる予定だったんだろう。
  (Queueに値が入ってきた時点で接続試行する?それだとResolution Delayを入れる余地がない…)
