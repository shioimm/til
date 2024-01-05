# 実装2
- `Addrinfo.getaddrinfo`を同じインターフェースで`Addrinfo.rb_getaddrinfo2_test`を呼び出せるようにした
- `rb_getaddrinfo`を`rb_getaddrinfo2`にコピーし、この後改修するための雛形を作った

```c
# ext/socket/raddrinfo.c

// 中身はrb_getaddrinfoのコピー
// TODO: pipeとstruct addrinfoのポインタを受け取り、名前解決後にそこに書き込むように修正する
static VALUE
rb_getaddrinfo2(const char *hostp, const char *portp, const struct addrinfo *hints, struct addrinfo **ai)
{
    int retry;
    struct getaddrinfo_arg *arg;
    int err;

start:
    retry = 0;

    arg = allocate_getaddrinfo_arg(hostp, portp, hints);
    if (!arg) {
        return EAI_MEMORY;
    }

    pthread_attr_t attr;
    if (pthread_attr_init(&attr) != 0) {
        free_getaddrinfo_arg(arg);
        return EAI_AGAIN;
    }
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
    if (do_pthread_create(&th, &attr, do_getaddrinfo, arg) != 0) {
        free_getaddrinfo_arg(arg);
        return EAI_AGAIN;
    }
    pthread_detach(th);

    rb_thread_call_without_gvl2(wait_getaddrinfo, arg, cancel_getaddrinfo, arg);

    int need_free = 0;
    rb_nativethread_lock_lock(&arg->lock);
    {
        if (arg->done) {
            err = arg->err;
            if (err == 0) *ai = arg->ai;
        }
        else if (arg->cancelled) {
            err = EAI_AGAIN;
        }
        else {
            // If already interrupted, rb_thread_call_without_gvl2 may return without calling wait_getaddrinfo.
            // In this case, it could be !arg->done && !arg->cancelled.
            arg->cancelled = 1; // to make do_getaddrinfo call freeaddrinfo
            retry = 1;
        }
        if (--arg->refcount == 0) need_free = 1;
    }
    rb_nativethread_lock_unlock(&arg->lock);

    if (need_free) free_getaddrinfo_arg(arg);

    // If the current thread is interrupted by asynchronous exception, the following raises the exception.
    // But if the current thread is interrupted by timer thread, the following returns; we need to manually retry.
    rb_thread_check_ints();
    if (retry) goto start;

    return err;
}

static VALUE
rb_getaddrinfo2_test(int argc, VALUE *argv, VALUE self)
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

    // getaddrinfoの実行
    struct rb_addrinfo *res;
    struct addrinfo *ai;
    char *hostp, *portp;
    char hbuf[NI_MAXHOST], pbuf[NI_MAXSERV];
    int additional_flags = 0;
    hostp = host_str(node, hbuf, sizeof(hbuf), &additional_flags);
    portp = port_str(service, pbuf, sizeof(pbuf), &additional_flags);

    // TODO: pipeとstruct addrinfoを渡し、スレッドの中で実行する
    rb_getaddrinfo2(hostp, portp, &hints, &ai);
    res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));

    res->allocated_by_malloc = 0;
    res->ai = ai;

    // 取得したaddrinfoからRubyオブジェクトを作成
    struct addrinfo *r;
    for (r = res->ai; r; r = r->ai_next) {
      printf("r->ai_addr %p\n", r->ai_addr);
    }

    // 後処理
    rb_freeaddrinfo(res);
    return Qnil;
}

void
rsock_init_addrinfo(void)
{
    // ...
    rb_define_singleton_method(rb_cAddrinfo, "rb_getaddrinfo2_test", rb_getaddrinfo2_test, -1);
    // ...
}
```

```c
# test/socket/test_addrinfo.rb

def test_rb_getaddrinfo2_test
  assert_equal nil, Addrinfo.rb_getaddrinfo2_test("localhost", 12345, nil, :STREAM)
end
```
