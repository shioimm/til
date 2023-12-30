# 2023/12/29 master
- `addrinfo_s_getaddrinfo` (ext/socket/raddrinfo.c)
  - `addrinfo_list_new`
    - `call_getaddrinfo`
      - `rsock_getaddrinfo`
        - `rb_getaddrinfo`
          - `do_pthread_create`
            - `do_getaddrinfo`
              - `getaddrinfo`
          - `wait_getaddrinfo`
          - `cancel_getaddrinfo`


```c
// ext/socket/raddrinfo.c

#include "rubysocket.h"

// GETADDRINFO_IMPL == 0 : call getaddrinfo/getnameinfo directly
// GETADDRINFO_IMPL == 1 : call getaddrinfo/getnameinfo without gvl (but uncancellable)
// GETADDRINFO_IMPL == 2 : call getaddrinfo/getnameinfo in a dedicated pthread
//                         (and if the call is interrupted, the pthread is detached)

#ifndef GETADDRINFO_IMPL
#  ifdef GETADDRINFO_EMU
#    define GETADDRINFO_IMPL 0
#  elif !defined(HAVE_PTHREAD_CREATE) || !defined(HAVE_PTHREAD_DETACH) || defined(__MINGW32__) || defined(__MINGW64__)
#    define GETADDRINFO_IMPL 1
#  else
#    define GETADDRINFO_IMPL 2
#    include "ruby/thread_native.h"
#  endif
#endif
```
