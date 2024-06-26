# 2024/1/6
- 関数名を実態に合わせて変更
- mainから`rb_getaddrinfo2`を呼ぶ際の引数にパイプを追加し、名前解決終了時にパイプへの書き込みを行うように変更
- mainではパイプへの書き込みをselectで待つように変更
- `rb_getaddrinfo`の実行をスレッドの中で行うように変更

```c
# ext/socket/raddrinfo.c

// 追加
#define HOSTNAME_RESOLUTION_PIPE_UPDATED "1"

// GETADDRINFO_IMPL == 1からコピー
struct rb_getaddrinfo2_arg
{
    const char *node;
    const char *service;
    const struct addrinfo *hints;
    struct addrinfo **ai;
    int writer; // 追加
};

// GETADDRINFO_IMPL == 1のnogvl_getaddrinfoとrsock_getaddrinfoを参考にしている
static void *
rb_getaddrinfo2(void *ptr)
{
    int ret;
    struct rb_getaddrinfo2_arg *arg = (struct rb_getaddrinfo2_arg *)ptr;
    ret = getaddrinfo(arg->node, arg->service, arg->hints, arg->ai);
#ifdef __linux__
    /* On Linux (mainly Ubuntu 13.04) /etc/nsswitch.conf has mdns4 and
     * it cause getaddrinfo to return EAI_SYSTEM/ENOENT. [ruby-list:49420]
     */
    if (ret == EAI_SYSTEM && errno == ENOENT)
        ret = EAI_NONAME;
#endif
    // 名前解決が終了したら書き込み
    write(arg->writer, HOSTNAME_RESOLUTION_PIPE_UPDATED, strlen(HOSTNAME_RESOLUTION_PIPE_UPDATED));
    return (void *)(VALUE)ret;
}

static VALUE
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

    // 引数を元にしてhintsに値を格納
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

    // getaddrinfoを実行するための準備
    struct addrinfo *ai = NULL;
    char *hostp, *portp;
    char hbuf[NI_MAXHOST], pbuf[NI_MAXSERV];
    int additional_flags = 0;
    hostp = host_str(node, hbuf, sizeof(hbuf), &additional_flags);
    portp = port_str(service, pbuf, sizeof(pbuf), &additional_flags);

    int pipefd[2];
    pipe(pipefd);

    struct rb_getaddrinfo2_arg arg;
    MEMZERO(&arg, struct rb_getaddrinfo2_arg, 1);
    arg.node = hostp;
    arg.service = portp;
    arg.hints = &hints;
    arg.ai = &ai;
    arg.writer = pipefd[1];

    // getaddrinfoの実行
    pthread_attr_t attr;
    pthread_attr_init(&attr);
#if defined(HAVE_PTHREAD_ATTR_SETAFFINITY_NP) && defined(HAVE_SCHED_GETCPU)
    cpu_set_t tmp_cpu_set;
    CPU_ZERO(&tmp_cpu_set);
    int cpu = sched_getcpu();
    if (cpu < CPU_SETSIZE) {
        CPU_SET(cpu, &tmp_cpu_set);
        pthread_attr_setaffinity_np(&attr, sizeof(cpu_set_t), &tmp_cpu_set);
    }
#endif
    pthread_t th;
    do_pthread_create(&th, 0, rb_getaddrinfo2, &arg);
    pthread_detach(th);

    // getaddrinfoの待機
    int retval;
    fd_set rfds;
    retval = select(pipefd[0] + 1, &rfds, NULL, NULL, NULL);

    if (retval < 0){
        perror("select()");
    }
    else if (retval > 0){
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
          return ret;
        }
        else {
          // TODO: 書き込まれた値を確認した上でraiseするようにした方が良い
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
