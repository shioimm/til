# 2024/1/11
- メモリの解放を正しく行う
- レビューの指摘事項を反映
  - `cancel_rb_getaddrinfo2`の中でargを参照する処理をロックする
  - 不要な`MEMZERO`を削除
- 最新のmasterに倣い、setaffinityを削除 (https://github.com/ruby/ruby/pull/9479)

```c
# ext/socket/raddrinfo.c

#define HOSTNAME_RESOLUTION_PIPE_UPDATED "1"

struct rb_getaddrinfo2_arg
{
    char *node, *service;
    struct addrinfo hints;
    struct addrinfo *ai;
    int err, refcount, cancelled; // 追加
    int writer; // 追加
    rb_nativethread_lock_t lock;
};

struct rb_getaddrinfo2_arg *
allocate_rb_getaddrinfo2_arg(const char *hostp, const char *portp, const struct addrinfo *hints)
{
    size_t hostp_offset = sizeof(struct rb_getaddrinfo2_arg);
    size_t portp_offset = hostp_offset + (hostp ? strlen(hostp) + 1 : 0);
    size_t bufsize = portp_offset + (portp ? strlen(portp) + 1 : 0);

    char *buf = malloc(bufsize);
    if (!buf) {
        rb_gc();
        buf = malloc(bufsize);
        if (!buf) return NULL;
    }
    struct rb_getaddrinfo2_arg *arg = (struct rb_getaddrinfo2_arg *)buf;

    if (hostp) {
        arg->node = buf + hostp_offset;
        strcpy(arg->node, hostp);
    }
    else {
        arg->node = NULL;
    }

    if (portp) {
        arg->service = buf + portp_offset;
        strcpy(arg->service, portp);
    }
    else {
        arg->service = NULL;
    }

    arg->hints = *hints;
    arg->ai = NULL;
    arg->refcount = 2;

    return arg;
}

void
free_rb_getaddrinfo2_arg(struct rb_getaddrinfo2_arg *arg)
{
    free(arg);
}

// GETADDRINFO_IMPL == 1のnogvl_getaddrinfoとrsock_getaddrinfoを参考にしている
void *
do_rb_getaddrinfo2(void *ptr)
{
    struct rb_getaddrinfo2_arg *arg = (struct rb_getaddrinfo2_arg *)ptr;

    int err;
    err = getaddrinfo(arg->node, arg->service, &arg->hints, &arg->ai);
#ifdef __linux__
    /* On Linux (mainly Ubuntu 13.04) /etc/nsswitch.conf has mdns4 and
     * it cause getaddrinfo to return EAI_SYSTEM/ENOENT. [ruby-list:49420]
     */
    if (err == EAI_SYSTEM && errno == ENOENT)
        err = EAI_NONAME;
#endif

    int need_free = 0;
    rb_nativethread_lock_lock(&arg->lock);
    {
        arg->err = err;
        if (arg->cancelled) {
            freeaddrinfo(arg->ai);
        }
        else {
            write(arg->writer, HOSTNAME_RESOLUTION_PIPE_UPDATED, strlen(HOSTNAME_RESOLUTION_PIPE_UPDATED));
        }
        if (--arg->refcount == 0) need_free = 1;
    }
    rb_nativethread_lock_unlock(&arg->lock);

    if (need_free) free_rb_getaddrinfo2_arg(arg);

    return 0;
}

struct wait_rb_getaddrinfo2_arg
{
    int reader;
    int retval;
    fd_set *rfds;
};

void *
wait_rb_getaddrinfo2(void *ptr)
{
    struct wait_rb_getaddrinfo2_arg *arg = (struct wait_rb_getaddrinfo2_arg *)ptr;
    int retval;
    retval = select(arg->reader + 1, arg->rfds, NULL, NULL, NULL);
    arg->retval = retval;
    return 0;
}

void
cancel_rb_getaddrinfo2(void *ptr)
{
    struct rb_getaddrinfo2_arg *arg = (struct rb_getaddrinfo2_arg *)ptr;
    rb_nativethread_lock_lock(&arg->lock);
    {
      arg->cancelled = 1;
    }
    rb_nativethread_lock_unlock(&arg->lock);
}

VALUE
rb_getaddrinfo2_main(int argc, VALUE *argv, VALUE self)
{
    // 引数の処理
    VALUE node, service, family, socktype, protocol, flags, opts, timeout;

    rb_scan_args(argc, argv, "24:", &node, &service, &family, &socktype,
                 &protocol, &flags, &opts);
    rb_get_kwargs(opts, &id_timeout, 0, 1, &timeout);
    if (timeout == Qundef) {
        timeout = Qnil;
    }

    // 引数を元にしてhintsに値を格納 (rsock_addrinfoに該当)
    struct addrinfo hints;
    MEMZERO(&hints, struct addrinfo, 1);
    hints.ai_family = NIL_P(family) ? PF_UNSPEC : rsock_family_arg(family);

    if (!NIL_P(socktype)) {
        hints.ai_socktype = rsock_socktype_arg(socktype);
    }
    if (!NIL_P(protocol)) {
        hints.ai_protocol = NUM2INT(protocol);
    }
    if (!NIL_P(flags)) {
        hints.ai_flags = NUM2INT(flags);
    }

    // getaddrinfoを実行するための準備 (rsock_getaddrinfoに該当)
    struct addrinfo *ai;
    int error;
    char *hostp, *portp;
    char hbuf[NI_MAXHOST], pbuf[NI_MAXSERV];
    int additional_flags = 0;
    hostp = host_str(node, hbuf, sizeof(hbuf), &additional_flags);
    portp = port_str(service, pbuf, sizeof(pbuf), &additional_flags);

    // do_rb_getaddrinfo2に渡す引数の準備
    int pipefd[2];
    pipe(pipefd);
    rb_nativethread_lock_t lock;
    rb_nativethread_lock_initialize(&lock);

    struct rb_getaddrinfo2_arg *arg;
    arg = allocate_rb_getaddrinfo2_arg(hostp, portp, &hints); // TODO &外したい
    if (!arg) {
        return EAI_MEMORY;
    }

    arg->writer = pipefd[1];
    arg->lock = lock;

    // getaddrinfoの実行
    pthread_t th;
    if (do_pthread_create(&th, do_rb_getaddrinfo2, arg) != 0) {
        free_rb_getaddrinfo2_arg(arg);
        return EAI_AGAIN;
    }
    pthread_detach(th);

    // getaddrinfoの待機
    int retval;
    fd_set rfds;
    struct wait_rb_getaddrinfo2_arg wait_arg;
    wait_arg.rfds = &rfds;
    wait_arg.reader = pipefd[0];
    rb_thread_call_without_gvl2(wait_rb_getaddrinfo2, &wait_arg, cancel_rb_getaddrinfo2, &arg);

    retval = wait_arg.retval;
    int need_free = 0;

    if (retval < 0){
        // selectの実行失敗。SystemCallError?
        rsock_raise_resolution_error("rb_getaddrinfo2_main", EAI_SYSTEM);
    }
    else if (retval > 0){
        error = arg->err;
        if (error == 0) {
            ai = arg->ai;
            char result[4];
            read(pipefd[0], result, sizeof result);
            if (strncmp(result, HOSTNAME_RESOLUTION_PIPE_UPDATED, sizeof HOSTNAME_RESOLUTION_PIPE_UPDATED) == 0) {
              printf("\nHostname resolurion finished\n");

              // 動作確認のため取得したaddrinfoからRubyオブジェクトを作成
              struct rb_addrinfo *res;
              res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
              res->allocated_by_malloc = 0;
              res->ai = ai;
              struct addrinfo *r;
              VALUE inspectname = make_inspectname(node, service, res->ai);
              VALUE ret = rb_ary_new();
              for (r = res->ai; r; r = r->ai_next) {
                  VALUE addr;
                  VALUE canonname = Qnil;

                  if (r->ai_canonname) {
                      canonname = rb_str_new_cstr(r->ai_canonname);
                      OBJ_FREEZE(canonname);
                  }

                  addr = rsock_addrinfo_new(r->ai_addr, r->ai_addrlen,
                                            r->ai_family, r->ai_socktype, r->ai_protocol,
                                            canonname, inspectname);

                  rb_ary_push(ret, addr);
                  printf("r->ai_addr %p\n", r->ai_addr);
              }

              // 後処理
              rb_freeaddrinfo(res);
              rb_nativethread_lock_lock(&lock);
              {
                if (--arg->refcount == 0) need_free = 1;
              }
              rb_nativethread_lock_unlock(&lock);
              if (need_free) free_rb_getaddrinfo2_arg(arg);
              return ret;
            }
            else {
              rb_nativethread_lock_lock(&lock);
              {
                if (--arg->refcount == 0) need_free = 1;
              }
              rb_nativethread_lock_unlock(&lock);
              if (need_free) free_rb_getaddrinfo2_arg(arg);

              rsock_raise_resolution_error("rb_getaddrinfo2_main", error);
            }
        }
        else {
          // selectの返り値が0 = 時間切れの場合。いったんこのまま
          return Qnil;
        }
    }
    return Qnil;
}

void
rsock_init_addrinfo(void)
{
    // ...
    rb_define_singleton_method(rb_cAddrinfo, "rb_getaddrinfo2_main", rb_getaddrinfo2_main, -1);
    // ...
}
```

```ruby
# test/socket/test_addrinfo.rb

def test_rb_getaddrinfo2_test
  assert_equal 12345, Addrinfo.rb_getaddrinfo2_main("localhost", 12345, nil, :STREAM).first.ip_port
end
```
