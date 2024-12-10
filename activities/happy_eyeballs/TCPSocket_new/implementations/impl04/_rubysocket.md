# 11/23

```c
char *host_str(VALUE host, char *hbuf, size_t hbuflen, int *flags_ptr);
char *port_str(VALUE port, char *pbuf, size_t pbuflen, int *flags_ptr);

#ifndef FAST_FALLBACK_INIT_INETSOCK_IMPL
#  if !defined(HAVE_PTHREAD_CREATE) || !defined(HAVE_PTHREAD_DETACH) || defined(__MINGW32__) || defined(__MINGW64__)
#    define FAST_FALLBACK_INIT_INETSOCK_IMPL 0
#  else
#    include "ruby/thread_native.h"
#    define FAST_FALLBACK_INIT_INETSOCK_IMPL 1
#    define IPV6_HOSTNAME_RESOLVED '1'
#    define IPV4_HOSTNAME_RESOLVED '2'
#    define SELECT_CANCELLED '3'

struct fast_fallback_getaddrinfo_entry
{
    int family, err, refcount;
    struct addrinfo hints;
    struct addrinfo *ai;
    struct fast_fallback_getaddrinfo_shared *shared;
    int has_syserr;
    long test_sleep_ms;
    int test_ecode;
};

struct fast_fallback_getaddrinfo_shared
{
    int notify, refcount;
    int cancelled;
    char *node, *service;
    rb_nativethread_lock_t lock;
    struct fast_fallback_getaddrinfo_entry getaddrinfo_entries[FLEX_ARY_LEN];
};

int raddrinfo_pthread_create(pthread_t *th, void *(*start_routine) (void *), void *arg);
void *do_fast_fallback_getaddrinfo(void *ptr);
void free_fast_fallback_getaddrinfo_entry(struct fast_fallback_getaddrinfo_entry **entry);
void free_fast_fallback_getaddrinfo_shared(struct fast_fallback_getaddrinfo_shared **shared);
#  endif
#endif

extern ID tcp_fast_fallback;
```
