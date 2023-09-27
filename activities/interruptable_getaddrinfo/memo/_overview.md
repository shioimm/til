# 全体構造
#### `Socket.getaddrinfo`
- `sock_s_getaddrinfo` (ext/socket/socket.c)
  - `rsock_getaddrinfo` (ext/socket/raddrinfo.c)

#### `Addrinfo.getaddrinfo`
- `addrinfo_s_getaddrinfo` (ext/socket/raddrinfo.c)
  - `addrinfo_list_new` (ext/socket/raddrinfo.c)
    - `call_getaddrinfo` (ext/socket/raddrinfo.c)
      - `rsock_getaddrinfo` (ext/socket/raddrinfo.c)

#### 共通
- `rsock_getaddrinfo`  (ext/socket/raddrinfo.c)
  - `numeric_getaddrinfo` (ext/socket/raddrinfo.c)
  - `rb_scheduler_getaddrinfo` (ext/socket/raddrinfo.c)
  - `getaddrinfo`
