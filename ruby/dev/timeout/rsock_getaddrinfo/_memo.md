# 2025/6/8時点

```c
// TODO timeoutを受け取れるように引数を増やす
struct rb_addrinfo*
rsock_addrinfo(VALUE host, VALUE port, int family, int socktype, int flags)
{
    struct addrinfo hints;

    MEMZERO(&hints, struct addrinfo, 1);
    hints.ai_family = family;
    hints.ai_socktype = socktype;
    hints.ai_flags = flags;
    return rsock_getaddrinfo(host, port, &hints, 1);
}
```

```c
// TODO timeoutを受け取れるように引数を増やす
struct rb_addrinfo*
rsock_getaddrinfo(VALUE host, VALUE port, struct addrinfo *hints, int socktype_hack)
{
    // ------- 準備 -------
    struct rb_addrinfo* res = NULL;
    struct addrinfo *ai;
    char *hostp, *portp;
    int error = 0;
    char hbuf[NI_MAXHOST], pbuf[NI_MAXSERV];
    int additional_flags = 0;

    hostp = raddrinfo_host_str(host, hbuf, sizeof(hbuf), &additional_flags);
    portp = raddrinfo_port_str(port, pbuf, sizeof(pbuf), &additional_flags);

    if (socktype_hack && hints->ai_socktype == 0 && str_is_number(portp)) {
        hints->ai_socktype = SOCK_DGRAM;
    }
    hints->ai_flags |= additional_flags;
    // ------- 準備 -------

    // ------- numeric_getaddrinfo -------
    error = numeric_getaddrinfo(hostp, portp, hints, &ai);

    // 渡された文字列hostpをパースしてIPアドレスかどうかを判断し、
    // IPアドレスの場合はstruct addrinfoにして返しているだけなのでタイムアウト不要かも

    if (error == 0) {
        res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
        res->allocated_by_malloc = 1;
        res->ai = ai;
    }
    // ------- numeric_getaddrinfo -------

    if (error != 0) {
        // ------- rb_scheduler_getaddrinfo -------
        VALUE scheduler = rb_fiber_scheduler_current();
        int resolved = 0;

        // Fiber::Scheduler用。スケジューラの実装に依存しそう
        // 値だけ渡して実際の制御をスケジューラに任せるような方針はありかもしれないけどあとで考える
        if (scheduler != Qnil && hostp && !(hints->ai_flags & AI_NUMERICHOST)) {
            error = rb_scheduler_getaddrinfo(scheduler, host, portp, hints, &res);

            if (error != EAI_FAIL) {
                resolved = 1;
            }
        }
        // ------- rb_scheduler_getaddrinfo -------

        // ------- rb_getaddrinfo -------
        if (!resolved) {
            error = rb_getaddrinfo(hostp, portp, hints, &ai);
            if (error == 0) {
                res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
                res->allocated_by_malloc = 0;
                res->ai = ai;
            }
        }
        // ------- rb_getaddrinfo -------
    }

    // ------- エラー処理 -------
    if (error) {
        if (hostp && hostp[strlen(hostp)-1] == '\n') {
            rb_raise(rb_eSocket, "newline at the end of hostname");
        }
        rsock_raise_resolution_error("getaddrinfo", error);
    }
    // ------- エラー処理 -------

    return res;
}
```

#### `numeric_getaddrinfo`

```c
static int
numeric_getaddrinfo(
    const char *node, const char *service,
    const struct addrinfo *hints,
    struct addrinfo **res
) {
    // ...
    int port;

    // nodeがある、かつポート番号がvalidな場合
    static const struct {
        int socktype;
        int protocol;
    } list[] = {
        { SOCK_STREAM, IPPROTO_TCP },
        { SOCK_DGRAM, IPPROTO_UDP },
        { SOCK_RAW, 0 }
    };

    struct addrinfo *ai = NULL;
    int hint_family = hints ? hints->ai_family : PF_UNSPEC;
    int hint_socktype = hints ? hints->ai_socktype : 0;
    int hint_protocol = hints ? hints->ai_protocol : 0;
    char ipv4addr[4];
    char ipv6addr[16];

    // ...
    // nodeがIPv6アドレスを表す文字列である場合
    int i;
    for (i = numberof(list)-1; 0 <= i; i--) {
        if ((hint_socktype == 0 || hint_socktype == list[i].socktype) &&
            (hint_protocol == 0 || list[i].protocol == 0 || hint_protocol == list[i].protocol)) {
            struct addrinfo *ai0 = xcalloc(1, sizeof(struct addrinfo));
            struct sockaddr_in6 *sa = xmalloc(sizeof(struct sockaddr_in6));
            INIT_SOCKADDR_IN6(sa, sizeof(struct sockaddr_in6));
            memcpy(&sa->sin6_addr, ipv6addr, sizeof(ipv6addr));
            sa->sin6_port = htons(port);
            ai0->ai_family = PF_INET6;
            ai0->ai_socktype = list[i].socktype;
            ai0->ai_protocol = hint_protocol ? hint_protocol : list[i].protocol;
            ai0->ai_addrlen = sizeof(struct sockaddr_in6);
            ai0->ai_addr = (struct sockaddr *)sa;
            ai0->ai_canonname = NULL;
            ai0->ai_next = ai;
            ai = ai0;
        }
    }

    // ...
    // nodeがIPv4アドレスを表す文字列である場合
    int i;
    for (i = numberof(list)-1; 0 <= i; i--) {
        if ((hint_socktype == 0 || hint_socktype == list[i].socktype) &&
            (hint_protocol == 0 || list[i].protocol == 0 || hint_protocol == list[i].protocol)) {
            struct addrinfo *ai0 = xcalloc(1, sizeof(struct addrinfo));
            struct sockaddr_in *sa = xmalloc(sizeof(struct sockaddr_in));
            INIT_SOCKADDR_IN(sa, sizeof(struct sockaddr_in));
            memcpy(&sa->sin_addr, ipv4addr, sizeof(ipv4addr));
            sa->sin_port = htons(port);
            ai0->ai_family = PF_INET;
            ai0->ai_socktype = list[i].socktype;
            ai0->ai_protocol = hint_protocol ? hint_protocol : list[i].protocol;
            ai0->ai_addrlen = sizeof(struct sockaddr_in);
            ai0->ai_addr = (struct sockaddr *)sa;
            ai0->ai_canonname = NULL;
            ai0->ai_next = ai;
            ai = ai0;
        }
    }

    // ...
    if (ai) {
        *res = ai;
        return 0;
    }

    // そうでない場合は名前解決失敗
    return EAI_FAIL;
}
```

#### `rb_scheduler_getaddrinfo`

```c
static int
rb_scheduler_getaddrinfo(
    VALUE scheduler, // rb_fiber_scheduler_current();
    VALUE host, const char *service,
    const struct addrinfo *hints,
    struct rb_addrinfo **res
) {
    int error, res_allocated = 0, _additional_flags = 0;
    long i, len;
    struct addrinfo *ai, *ai_tail = NULL;
    char *hostp;
    char _hbuf[NI_MAXHOST];
    VALUE ip_addresses_array, ip_address;

    // 実際の実装はスケジューラ用のクラスに依存する
    ip_addresses_array = rb_fiber_scheduler_address_resolve(scheduler, host);

    // Returns EAI_FAIL if the scheduler hook is not implemented:
    if (ip_addresses_array == Qundef) return EAI_FAIL;

    if (ip_addresses_array == Qnil) {
        len = 0;
    } else {
        len = RARRAY_LEN(ip_addresses_array);
    }

    // ip_addresses_array (IPアドレスを表すRubyオブジェクトのC配列)
    for(i=0; i<len; i++) {
        ip_address = rb_ary_entry(ip_addresses_array, i);
        hostp = raddrinfo_host_str(ip_address, _hbuf, sizeof(_hbuf), &_additional_flags);
        error = numeric_getaddrinfo(hostp, service, hints, &ai);

        // IPアドレスをstruct addrinfoに詰め直している
        if (error == 0) {
            if (!res_allocated) {
                res_allocated = 1;
                *res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
                (*res)->allocated_by_malloc = 1;
                (*res)->ai = ai;
                ai_tail = ai;
            } else {
                while (ai_tail->ai_next) {
                    ai_tail = ai_tail->ai_next;
                }
                ai_tail->ai_next = ai;
                ai_tail = ai;
            }
        }
    }

    if (res_allocated) { // At least one valid result.
        return 0;
    } else {
        return EAI_NONAME;
    }
}
```

## 呼び出し側
- `rsock_getaddrinfo` <変更対象>
  - `rsock_addrinfo` <変更対象>
    - (なし) `sock_s_gethostbyname` (`Socket.gethostbyname`) [ext/socket/socket.c]
    - (なし) `sock_s_pack_sockaddr_in` (`Socket.sockaddr_in` / `Socket.pack_sockaddr_in`) [ext/socket/socket.c]
    -  `init_inetsock_internal` / `init_fast_fallback_inetsock_internal` [ext/socket/ipsocket.c] <対応中>
      - `rsock_init_inetsock` [ext/socket/ipsocket.c]
        - (なし -> あり) `tcp_init` (`TCPSocket#initialize`) [ext/socket/tcpsocket.c]
        - (なし) `socks_init` (`SOCKSSocket#initialize`) [ext/socket/sockssocket.c]
        - (なし) `tcp_svr_init` (`TCPServer#initialize`) [ext/socket/tcpserver.c]
    - (なし) `ip_s_getaddress` (`IPSocket.getaddress`) [ext/socket/ipsocket.c]
    - (なし) `tcp_s_gethostbyname` (`TCPSocket.gethostbyname`) (ext/socket/tcpsocket.c) [ext/socket/tcpsocket.c]
    - (なし) `udp_connect` (`UDPSocket#connect`) [ext/socket/udpsocket.c]
    - (なし) `udp_bind` (`UDPSocket#bind`) [ext/socket/udpsocket.c]
    - (なし) `udp_send` (`UDPSocket#send`) [ext/socket/udpsocket.c]
  - `call_getaddrinfo`
    - `init_addrinfo_getaddrinfo`
      - (なし) `addrinfo_initialize` (`Addrinfo#initialize`) [ext/socket/raddrinfo.c]
    - `addrinfo_firstonly_new`
      - (なし) `addrinfo_s_ip` (`Addrinfo.ip`) [ext/socket/raddrinfo.c]
      - (なし) `addrinfo_s_tcp` (`Addrinfo.tcp`) [ext/socket/raddrinfo.c]
      - (なし) `addrinfo_s_udp` (`Addrinfo.udp`) [ext/socket/raddrinfo.c]
    - `addrinfo_list_new`
      - (あり) `addrinfo_s_getaddrinfo` (`Addrinfo.getaddrinfo`) [ext/socket/raddrinfo.c]
    - (なし) `addrinfo_mload` (`Addrinfo.marshal_load`) [ext/socket/raddrinfo.c]
