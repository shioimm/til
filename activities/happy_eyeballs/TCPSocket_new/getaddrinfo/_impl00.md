# prototypes/02 時点

```c
// ext/socket/raddrinfo.c

void
close_fd(int fd)
{
    if (fd >= 0 && fcntl(fd, F_GETFL) != -1) close(fd);
}

void
free_rb_getaddrinfo_happy_shared(struct rb_getaddrinfo_happy_shared **shared)
{
    free((*shared)->node);
    (*shared)->node = NULL;
    free((*shared)->service);
    (*shared)->service = NULL;
    close_fd((*shared)->notify);
    close_fd((*shared)->wait);
    rb_nativethread_lock_destroy((*shared)->lock);
    free(*shared);
    *shared = NULL;
}

void
free_rb_getaddrinfo_happy_entry(struct rb_getaddrinfo_happy_entry **entry)
{
    if ((*entry)->ai) {
        freeaddrinfo((*entry)->ai);
        (*entry)->ai = NULL;
    }
    free(*entry);
    *entry = NULL;
}

// GETADDRINFO_IMPL == 1のnogvl_getaddrinfoとrsock_getaddrinfoを参考にしている
void *
do_rb_getaddrinfo_happy(void *ptr)
{
    struct rb_getaddrinfo_happy_entry *entry = (struct rb_getaddrinfo_happy_entry *)ptr;
    struct rb_getaddrinfo_happy_shared *shared = entry->shared;
    int err = 0, need_free = 0, shared_need_free = 0;

    err = numeric_getaddrinfo(shared->node, entry->shared->service, &entry->hints, &entry->ai);

    if (err != 0) {
        err = getaddrinfo(shared->node, entry->shared->service, &entry->hints, &entry->ai);
       #ifdef __linux__
       /* On Linux (mainly Ubuntu 13.04) /etc/nsswitch.conf has mdns4 and
        * it cause getaddrinfo to return EAI_SYSTEM/ENOENT. [ruby-list:49420]
        */
       if (err == EAI_SYSTEM && errno == ENOENT)
           err = EAI_NONAME;
       #endif
    }

    if (entry->sleep) usleep(entry->sleep);

    rb_nativethread_lock_lock(shared->lock);
    {
        entry->err = err;
        if (shared->cancelled) {
            if (entry->ai) {
                freeaddrinfo(entry->ai);
                entry->ai = NULL;
            }
        } else {
            if (entry->family == AF_INET6) {
                write(shared->notify, IPV6_HOSTNAME_RESOLVED, strlen(IPV6_HOSTNAME_RESOLVED));
            } else if (entry->family == AF_INET) {
                write(shared->notify, IPV4_HOSTNAME_RESOLVED, strlen(IPV4_HOSTNAME_RESOLVED));
            }
        }
        if (--(entry->refcount) == 0) need_free = 1;
        if (--(shared->refcount) == 0) shared_need_free = 1;
    }
    rb_nativethread_lock_unlock(shared->lock);

    if (need_free && entry) {
        free_rb_getaddrinfo_happy_entry(&entry);
    }
    if (shared_need_free && shared) {
        free_rb_getaddrinfo_happy_shared(&shared);
    }

    return 0;
}
```

```c
// ext/socket/rubysocket.h

// 変更 -------------------
VALUE rsock_init_inetsock(
  VALUE sock,
  VALUE remote_host,
  VALUE remote_serv,
  VALUE local_host,
  VALUE local_serv,
  int type,
  VALUE resolv_timeout,
  VALUE connect_timeout,
  VALUE fast_fallback
);
// -----------------------

// 追加 -------------------
#define IPV6_HOSTNAME_RESOLVED "1"
#define IPV4_HOSTNAME_RESOLVED "2"

char *host_str(VALUE host, char *hbuf, size_t hbuflen, int *flags_ptr);
char *port_str(VALUE port, char *pbuf, size_t pbuflen, int *flags_ptr);

struct rb_getaddrinfo_happy_shared {
    int wait, notify, refcount, connecting_fds_size;
    int *connecting_fds;
    bool cancelled;
    char *node, *service;
    rb_nativethread_lock_t *lock;
};

struct rb_getaddrinfo_happy_entry
{
    int family, err, refcount, sleep;
    struct addrinfo hints;
    struct addrinfo *ai;
    struct rb_getaddrinfo_happy_shared *shared;
};

void close_fd(int fd);
int do_pthread_create(pthread_t *th, void *(*start_routine) (void *), void *arg);
void * do_rb_getaddrinfo_happy(void *ptr);
void free_rb_getaddrinfo_happy_entry(struct rb_getaddrinfo_happy_entry **entry);
void free_rb_getaddrinfo_happy_shared(struct rb_getaddrinfo_happy_shared **shared);
// -------------------------
```
