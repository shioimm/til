# 9/21-

```c
// ext/socket/raddrinfo.c

#if FAST_FALLBACK_INIT_INETSOCK_IMPL == 1

void
free_fast_fallback_getaddrinfo_shared(struct fast_fallback_getaddrinfo_shared **shared)
{
    xfree((*shared)->node);
    (*shared)->node = NULL;
    xfree((*shared)->service);
    (*shared)->service = NULL;
    rb_nativethread_lock_destroy(&(*shared)->lock);
    free(*shared);
    *shared = NULL;
}

void
free_fast_fallback_getaddrinfo_entry(struct fast_fallback_getaddrinfo_entry **entry)
{
    if ((*entry)->ai) {
        freeaddrinfo((*entry)->ai);
        (*entry)->ai = NULL;
    }
    *entry = NULL;
}

static void *
do_fast_fallback_getaddrinfo(void *ptr)
{
    struct fast_fallback_getaddrinfo_entry *entry = (struct fast_fallback_getaddrinfo_entry *)ptr;
    struct fast_fallback_getaddrinfo_shared *shared = entry->shared;
    int err = 0, need_free = 0, shared_need_free = 0;

    sigset_t set;
    sigemptyset(&set);
    sigaddset(&set, SIGPIPE);
    pthread_sigmask(SIG_BLOCK, &set, NULL);

    err = numeric_getaddrinfo(shared->node, shared->service, &entry->hints, &entry->ai);

    if (err != 0) {
        err = getaddrinfo(shared->node, shared->service, &entry->hints, &entry->ai);
       #ifdef __linux__
       /* On Linux (mainly Ubuntu 13.04) /etc/nsswitch.conf has mdns4 and
        * it cause getaddrinfo to return EAI_SYSTEM/ENOENT. [ruby-list:49420]
        */
       if (err == EAI_SYSTEM && errno == ENOENT)
           err = EAI_NONAME;
       #endif
    }

    /* for testing HEv2 */
    if (entry->test_sleep_ms > 0) {
        struct timespec sleep_ts;
        sleep_ts.tv_sec = entry->test_sleep_ms / 1000;
        sleep_ts.tv_nsec = (entry->test_sleep_ms % 1000) * 1000000L;
        if (sleep_ts.tv_nsec >= 1000000000L) {
            sleep_ts.tv_sec += sleep_ts.tv_nsec / 1000000000L;
            sleep_ts.tv_nsec = sleep_ts.tv_nsec % 1000000000L;
        }
        nanosleep(&sleep_ts, NULL);
    }
    if (entry->test_ecode != 0) {
        err = entry->test_ecode;
        if (entry->ai) {
            freeaddrinfo(entry->ai);
            entry->ai = NULL;
        }
    }

    rb_nativethread_lock_lock(&shared->lock);
    {
        entry->err = err;
        const char notification = entry->family == AF_INET6 ?
        IPV6_HOSTNAME_RESOLVED : IPV4_HOSTNAME_RESOLVED;

        if (shared->notify != -1 && (write(shared->notify, &notification, 1)) < 0) {
            entry->err = errno;
            entry->has_syserr = true;
        }
        if (--(entry->refcount) == 0) need_free = 1;
        if (--(shared->refcount) == 0) shared_need_free = 1;
    }
    rb_nativethread_lock_unlock(&shared->lock);

    if (need_free && entry) {
        free_fast_fallback_getaddrinfo_entry(&entry);
    }
    if (shared_need_free && shared) {
        free_fast_fallback_getaddrinfo_shared(&shared);
    }

    return 0;
}

void *
fork_safe_do_fast_fallback_getaddrinfo(void *ptr)
{
    return rb_thread_prevent_fork(do_fast_fallback_getaddrinfo, ptr);
}

#endif
```

```c
// ext/socket/rubysocket.h

VALUE rsock_init_inetsock(VALUE sock, VALUE remote_host, VALUE remote_serv, VALUE local_host, VALUE local_serv, int type, VALUE resolv_timeout, VALUE connect_timeout, VALUE fast_fallback, VALUE test_mode_settings);

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
```

## メモ

- 書き込み先のパイプがすでに終了している場合に異常終了しないようにする

```c
sigset_t set;
sigemptyset(&set);
sigaddset(&set, SIGPIPE);
pthread_sigmask(SIG_BLOCK, &set, NULL);
```
