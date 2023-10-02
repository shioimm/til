# 中断可能な`rsock_getaddrinfo`の実装

```c
// ext/socket/raddrinfo.c
struct getaddrinfo_arg
{
  const char *node;
  const char *service;
  const struct addrinfo *hints;
  struct addrinfo **res;
  // 以下追加
  VALUE queue;
  int ret;
};
```

```c
int
rb_getaddrinfo(
  const char *node,
  const char *service,
  const struct addrinfo *hints,
  struct rb_addrinfo **res
) {
  struct addrinfo *ai;
  int ret;
  int allocated_by_malloc = 0;
  ret = numeric_getaddrinfo(node, service, hints, &ai);

  if (ret == 0) {
    allocated_by_malloc = 1;
  } else {
#ifdef GETADDRINFO_EMU
    ret = getaddrinfo(node, service, hints, &ai);
#else
    // 以下削除
    //   struct getaddrinfo_arg arg;
    //   MEMZERO(&arg, struct getaddrinfo_arg, 1);
    //   arg.node = node;
    //   arg.service = service;
    //   arg.hints = hints;
    //   arg.res = &ai;
    //   ret = (int)(VALUE)rb_thread_call_without_gvl(nogvl_getaddrinfo, &arg, RUBY_UBF_IO, 0);

    // 以下追加
    struct getaddrinfo_arg *ptr;
    VALUE arg_wrapper = TypedData_Make_Struct(0, struct getaddrinfo_arg, &getaddrinfo_arg_data_type, ptr);
    MEMZERO(ptr, struct getaddrinfo_arg, 1);
    ptr->node = node;
    ptr->service = service;
    ptr->hints = hints;
    ptr->res = &ai;
    ptr->queue = rb_queue_new();
    rb_szqueue_push(1, &arg_wrapper, getaddrinfo_queue);

    if (NUM2INT(rb_szqueue_num_waiting(getaddrinfo_queue)) == 0) {
      rb_thread_create(start_getaddrinfo, NULL);
    }

    ret = FIX2INT(rb_queue_pop(0, NULL, ptr->queue));
#endif
  }

  if (ret == 0) {
    *res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
    (*res)->allocated_by_malloc = allocated_by_malloc;
    (*res)->ai = ai;
  }

  return ret;
}
```

```c
VALUE getaddrinfo_queue;

static void
getaddrinfo_arg_mark(void *ptr)
{
  struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)ptr;
  rb_gc_mark(arg->queue);
}

static void
getaddrinfo_arg_free(void *ptr)
{
  struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)ptr;
  ruby_xfree(arg);
}

static size_t
getaddrinfo_arg_memsize(const void *ptr)
{
  return sizeof(struct getaddrinfo_arg);
}

static const rb_data_type_t getaddrinfo_arg_data_type = {
  "socket/getaddrinfo_arg",
  {getaddrinfo_arg_mark, getaddrinfo_arg_free, getaddrinfo_arg_memsize,},
};

static VALUE
push_getaddrinfo_result(VALUE arg)
{
  struct getaddrinfo_arg *ptr = (struct getaddrinfo_arg *)arg;
  return rb_queue_push(ptr->queue, INT2FIX(ptr->ret));
}

static VALUE
start_getaddrinfo(void *unused)
{
  struct getaddrinfo_arg *ptr;
  VALUE arg_wrapper;

  while (NUM2INT(rb_szqueue_num_waiting(getaddrinfo_queue)) == 0) {
    arg_wrapper = rb_szqueue_pop(0, NULL, getaddrinfo_queue);
    if (NIL_P(arg_wrapper)) { break; }
    TypedData_Get_Struct(arg_wrapper, struct getaddrinfo_arg, &getaddrinfo_arg_data_type, ptr);
    ptr->ret = (int)(VALUE)rb_thread_call_without_gvl(nogvl_getaddrinfo, ptr, RUBY_UBF_IO, 0);
    rb_protect(push_getaddrinfo_result, (VALUE)ptr, NULL);
  }

  return Qnil;
}
```

```c
void
rsock_init_addrinfo(void)
{
  // ...
  getaddrinfo_queue = rb_szqueue_new(20); // same as maximal number of threads in getaddrinfo_a(3)
  rb_gc_register_mark_object(getaddrinfo_queue);
  // ...
}
```

```c
// include/ruby/internal/intern/thread.h

VALUE rb_queue_new(void);
VALUE rb_queue_push(VALUE self, VALUE obj);
VALUE rb_queue_pop(int argc, VALUE *argv, VALUE self);

VALUE rb_szqueue_new(long max);
VALUE rb_szqueue_push(int argc, VALUE *argv, VALUE self);
VALUE rb_szqueue_pop(int argc, VALUE *argv, VALUE self);
VALUE rb_szqueue_num_waiting(VALUE self);
```

```c
// thread_sync.c
VALUE
rb_queue_new(void)
{
  VALUE self = queue_alloc(rb_cQueue);
  struct rb_queue *q = queue_ptr(self);
  RB_OBJ_WRITE(self, &q->que, ary_buf_new());
  list_head_init(queue_waitq(q));
  return self;
}

VALUE
rb_szqueue_new(long max)
{
  VALUE self = szqueue_alloc(rb_cSizedQueue);
  struct rb_szqueue *sq = szqueue_ptr(self);

  if (max <= 0) {
    rb_raise(rb_eArgError, "queue size must be positive");
  }

  RB_OBJ_WRITE(self, &sq->q.que, ary_buf_new());
  list_head_init(szqueue_waitq(sq));
  list_head_init(szqueue_pushq(sq));
  sq->max = max;

  return self;
}

// このほかに
// rb_queue_push
// rb_queue_pop
// rb_szqueue_push
// rb_szqueue_pop
// rb_szqueue_num_waiting
// からstaticを外している
```
