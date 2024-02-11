# 2024/2/8
- 待機用関数`wait_rb_getaddrinfo_happy`を`wait_happy_eyeballs_fds`へrenameしてext/socket/ipsocket.cへ移動
- UBF`cancel_rb_getaddrinfo_happy`を`cancel_happy_eyeballs_fds`へrenameしてext/socket/ipsocket.cへ移動
- `free_rb_getaddrinfo_happy`時にMutexのロックを削除するようにした

```c
# ext/socket/raddrinfo.c

#define HOSTNAME_RESOLUTION_PIPE_UPDATED "1"

void
free_rb_getaddrinfo_happy_arg(struct rb_getaddrinfo_happy_arg *arg)
{
    rb_nativethread_lock_destroy(&arg->lock);
    free(arg);
}

// GETADDRINFO_IMPL == 1のnogvl_getaddrinfoとrsock_getaddrinfoを参考にしている
void *
do_rb_getaddrinfo_happy(void *ptr)
{
    struct rb_getaddrinfo_happy_arg *arg = (struct rb_getaddrinfo_happy_arg *)ptr;

    int err = 0;
    err = numeric_getaddrinfo(arg->node, arg->service, &arg->hints, &arg->ai);
    if (err != 0) {
        err = getaddrinfo(arg->node, arg->service, &arg->hints, &arg->ai);
       #ifdef __linux__
       /* On Linux (mainly Ubuntu 13.04) /etc/nsswitch.conf has mdns4 and
        * it cause getaddrinfo to return EAI_SYSTEM/ENOENT. [ruby-list:49420]
        */
       if (err == EAI_SYSTEM && errno == ENOENT)
           err = EAI_NONAME;
       #endif
    }

    int need_free = 0;
    rb_nativethread_lock_lock(&arg->lock);
    {
        arg->err = err;
        if (arg->cancelled) {
            freeaddrinfo(arg->ai);
        }
        else {
            write(arg->writer, HOSTNAME_RESOLUTION_PIPE_UPDATED, strlen(HOSTNAME_RESOLUTION_PIPE_UPDATED));
        }
        if (--arg->refcount == 0) need_free = 1;
    }
    rb_nativethread_lock_unlock(&arg->lock);

    if (need_free) free_rb_getaddrinfo_happy_arg(arg);

    return 0;
}
```

```c
// ext/socket/rubysocket.h

// 追加 -------------------
#define HOSTNAME_RESOLUTION_PIPE_UPDATED "1"

char *host_str(VALUE host, char *hbuf, size_t hbuflen, int *flags_ptr);
char *port_str(VALUE port, char *pbuf, size_t pbuflen, int *flags_ptr);

struct rb_getaddrinfo_happy_arg
{
    char *node, *service;
    struct addrinfo hints;
    struct addrinfo *ai;
    int err, refcount, cancelled;
    int writer;
    rb_nativethread_lock_t lock;
};

int do_pthread_create(pthread_t *th, void *(*start_routine) (void *), void *arg);
void * do_rb_getaddrinfo_happy(void *ptr);
void free_rb_getaddrinfo_happy_arg(struct rb_getaddrinfo_happy_arg *arg);
// -------------------------
```

```ruby
# test/socket/test_addrinfo.rb

def test_rb_getaddrinfo_happy_test
  assert_equal 12345, Addrinfo.rb_getaddrinfo_happy_main("localhost", 12345, nil, :STREAM).first.ip_port
end
```
