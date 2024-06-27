# 全体構造
#### `Socket.getaddrinfo`
- `sock_s_getaddrinfo` (ext/socket/socket.c)
  - `rsock_getaddrinfo` (ext/socket/raddrinfo.c)

#### `Addrinfo.getaddrinfo`
- `addrinfo_s_getaddrinfo` (ext/socket/raddrinfo.c)
  - `addrinfo_list_new` (ext/socket/raddrinfo.c)
    - `call_getaddrinfo` (ext/socket/raddrinfo.c) (引数でtimeoutを受け取っているが`rsock_getaddrinfo`に渡していない)
      - `rsock_getaddrinfo` (ext/socket/raddrinfo.c)

#### 共通
- `rsock_getaddrinfo`  (ext/socket/raddrinfo.c)
  - `numeric_getaddrinfo` (ext/socket/raddrinfo.c)
  - `rb_scheduler_getaddrinfo` (ext/socket/raddrinfo.c)
  - `getaddrinfo`

#### 共通 (変更後)
- `rsock_getaddrinfo`  (ext/socket/raddrinfo.c)
  - `numeric_getaddrinfo` (ext/socket/raddrinfo.c)
  - `rb_scheduler_getaddrinfo` (ext/socket/raddrinfo.c)
  - `rb_getaddrinfo`
    - `if GETADDRINFO_IMPL == 0`
      - `getaddrinfo`
    - `if GETADDRINFO_IMPL == 1`
      - `rb_thread_call_without_gvl`
        - `nogvl_getaddrinfo`
          - `getaddrinfo`
    - `if GETADDRINFO_IMPL == 2`
      - `do_pthread_create`
        - `do_getaddrinfo`
      - `rb_thread_call_without_gvl2`
        - `wait_getaddrinfo`
