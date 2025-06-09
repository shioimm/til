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
