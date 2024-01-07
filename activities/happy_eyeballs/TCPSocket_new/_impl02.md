# 2024/1/5
- `GETADDRINFO_IMPL == 1`とinterruptable getaddrinfo導入前の`rsock_getaddrinfo`を参考に
  名前解決用の関数をシングルスレッドで行うようにした
- 動作確認のため、`Addrinfo.rb_getaddrinfo2_test`の返り値を`Addrinfo`オブジェクトにした

```c
# ext/socket/raddrinfo.c

// GETADDRINFO_IMPL == 1からコピー
struct getaddrinfo_arg2
{
    const char *node;
    const char *service;
    const struct addrinfo *hints;
    struct addrinfo **res;
};

// GETADDRINFO_IMPL == 1からコピー
static void *
nogvl_getaddrinfo(void *arg)
{
    int ret;
    struct getaddrinfo_arg2 *ptr = arg;
    ret = getaddrinfo(ptr->node, ptr->service, ptr->hints, ptr->res);
#ifdef __linux__
    /* On Linux (mainly Ubuntu 13.04) /etc/nsswitch.conf has mdns4 and
     * it cause getaddrinfo to return EAI_SYSTEM/ENOENT. [ruby-list:49420]
     */
    if (ret == EAI_SYSTEM && errno == ENOENT)
        ret = EAI_NONAME;
#endif
    return (void *)(VALUE)ret;
}

// interruptable getaddrinfo 導入前のrsock_getaddrinfoを参考にしている
// TODO: pipeとstruct addrinfoのポインタを受け取り、名前解決後にそこに書き込むように修正する
static int
rb_getaddrinfo2(const char *hostp, const char *portp, const struct addrinfo *hints, struct addrinfo **ai)
{
    int error = 0;
    struct getaddrinfo_arg2 arg;
    MEMZERO(&arg, struct getaddrinfo_arg2, 1);
    arg.node = hostp;
    arg.service = portp;
    arg.hints = hints;
    arg.res = ai;

    error = (int)(VALUE)rb_thread_call_without_gvl(nogvl_getaddrinfo, &arg, RUBY_UBF_IO, 0);

    return error;
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
    struct addrinfo *ai;
    char *hostp, *portp;
    char hbuf[NI_MAXHOST], pbuf[NI_MAXSERV];
    int additional_flags = 0;
    hostp = host_str(node, hbuf, sizeof(hbuf), &additional_flags);
    portp = port_str(service, pbuf, sizeof(pbuf), &additional_flags);

    // TODO: pipeとstruct addrinfoを渡し、スレッドの中で実行する
    rb_getaddrinfo2(hostp, portp, &hints, &ai); // エラーの場合は-1が返ってくる

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

void
rsock_init_addrinfo(void)
{
    // ...
    rb_define_singleton_method(rb_cAddrinfo, "rb_getaddrinfo2_test", rb_getaddrinfo2_test, -1);
    // ...
}
```

```ruby
# test/socket/test_addrinfo.rb

def test_rb_getaddrinfo2_test
  assert_equal 12345, Addrinfo.rb_getaddrinfo2_test("localhost", 12345, nil, :STREAM).first.ip_port
end
```
