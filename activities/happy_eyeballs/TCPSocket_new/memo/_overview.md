# 全体構造
1. `rsock_init_tcpsocket` (ext/socket/tcpsocket.c)
2. `tcp_init` (ext/socket/tcpsocket.c)
3. `rsock_init_inetsock` (ext/socket/ipsocket.c)
4. `rb_ensure`
5. `init_inetsock_internal` (ext/socket/ipsocket.c)
    - `rsock_addrinfo` (ext/socket/raddrinfo.c)
      - `rsock_getaddrinfo` (ext/socket/raddrinfo.c)
        - `getaddrinfo(2)`
    - `rsock_socket` (ext/socket/init.c)
      - `rsock_socket0` (ext/socket/init.c)
    - `rsock_connect` (ext/socket/init.c)
      - `rb_thread_io_blocking_region` (thread.c)
        - `connect(2)`
    - `rsock_init_sock` (ext/socket/init.c)
6. (ensure) `inetsock_cleanup` (ext/socket/ipsocket.c)
