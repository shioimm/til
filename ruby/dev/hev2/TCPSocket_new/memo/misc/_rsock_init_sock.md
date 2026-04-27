# `rsock_init_sock`

```c
// ext/socket/init.c

VALUE
rsock_init_sock(VALUE sock, int fd)
{
    rb_io_t *fp;

    rb_update_max_fd(fd);
    MakeOpenFile(sock, fp);
    fp->fd = fd; // 接続済みのファイルディスクリプタ
    fp->mode = FMODE_READWRITE|FMODE_DUPLEX; // フラグ
    rb_io_ascii8bit_binmode(sock);

    if (rsock_do_not_reverse_lookup) {
        fp->mode |= FMODE_NOREVLOOKUP;
    }

    rb_io_synchronized(fp);

    return sock;
}

// include/ruby/io.h
//   #define MakeOpenFile RB_IO_OPEN
//   /**
//    * Fills an IO object.  This makes the best sense when called from inside of an
//    * `#initialize`  method  of  a  3rd  party  extension  library  that  inherits
//    * ::rb_cIO.
//    *
//    * If the passed  IO is already opened  for something it first  closes that and
//    * opens a new one instead.
//    *
//    * @param[out]  obj              An IO object to fill in.
//    * @param[out]  fp               A variable of type ::rb_io_t.
//    * @exception   rb_eTypeError    `obj` is not ::RUBY_T_FILE.
//    * @post        `fp` holds `obj`'s underlying IO.
//    */
//   #define RB_IO_OPEN(obj, fp) do {\
//       (fp) = rb_io_make_open_file(obj);\
//   } while (0)
//
// io.c
//   rb_io_t *
//   rb_io_make_open_file(VALUE obj)
//   {
//       rb_io_t *fp = 0;
//
//       Check_Type(obj, T_FILE);
//       if (RFILE(obj)->fptr) {
//           rb_io_close(obj);
//           rb_io_fptr_finalize(RFILE(obj)->fptr);
//           RFILE(obj)->fptr = 0;
//       }
//       fp = rb_io_fptr_new();
//       fp->self = obj;
//       RFILE(obj)->fptr = fp;
//       return fp;
//   }
```

```c
// io.c

VALUE
rb_io_ascii8bit_binmode(VALUE io)
{
    rb_io_t *fptr;

    GetOpenFile(io, fptr);
    io_ascii8bit_binmode(fptr);

    return io;
}

// include/ruby/io.h
//   #define GetOpenFile RB_IO_POINTER
//
//   /**
//    * Queries the underlying IO pointer.
//    *
//    * @param[in]   obj              An IO object.
//    * @param[out]  fp               A variable of type ::rb_io_t.
//    * @exception   rb_eFrozenError  `obj` is frozen.
//    * @exception   rb_eIOError      `obj` is closed.
//    * @post        `fp` holds `obj`'s underlying IO.
//    */
//   #define RB_IO_POINTER(obj,fp) rb_io_check_closed((fp) = RFILE(rb_io_taint_check(obj))->fptr)

void
rb_io_check_closed(rb_io_t *fptr)
{
    rb_io_check_initialized(fptr);
    io_fd_check_closed(fptr->fd);
}
```

```c
// io.c

void
rb_io_synchronized(rb_io_t *fptr)
{
    rb_io_check_initialized(fptr);
    fptr->mode |= FMODE_SYNC;
}

void
rb_io_check_initialized(rb_io_t *fptr)
{
    if (!fptr) rb_raise(rb_eIOError, "uninitialized stream");
}
```

```c
// 参考
// include/ruby/io.h

/** Ruby's IO, metadata and buffers. */
struct rb_io {
    /** The IO's Ruby level counterpart. */
    VALUE self;

    /** stdio ptr for read/write, if available. */
    FILE *stdio_file;

    /** file descriptor. */
    int fd;

    /** mode flags: FMODE_XXXs */
    int mode;

    /** child's pid (for pipes) */
    rb_pid_t pid;

    /** number of lines read */
    int lineno;

    /** pathname for file */
    VALUE pathv;

    /** finalize proc */
    void (*finalize)(struct rb_io*,int);

    /** Write buffer. */
    rb_io_buffer_t wbuf;

    /**
     * (Byte)  read   buffer.   Note  also   that  there  is  a   field  called
     * ::rb_io_t::cbuf, which also concerns read IO.
     */
    rb_io_buffer_t rbuf;

    /**
     * Duplex IO object, if set.
     *
     * @see rb_io_set_write_io()
     */
    VALUE tied_io_for_writing;

    struct rb_io_encoding encs; /**< Decomposed encoding flags. */

    /** Encoding converter used when reading from this IO. */
    rb_econv_t *readconv;

    /**
     * rb_io_ungetc()  destination.   This  buffer   is  read  before  checking
     * ::rb_io_t::rbuf
     */
    rb_io_buffer_t cbuf;

    /** Encoding converter used when writing to this IO. */
    rb_econv_t *writeconv;

    /**
     * This is, when set, an instance  of ::rb_cString which holds the "common"
     * encoding.   Write  conversion  can  convert strings  twice...   In  case
     * conversion from encoding  X to encoding Y does not  exist, Ruby finds an
     * encoding Z that bridges the two, so that X to Z to Y conversion happens.
     */
    VALUE writeconv_asciicompat;

    /** Whether ::rb_io_t::writeconv is already set up. */
    int writeconv_initialized;

    /**
     * Value   of    ::rb_io_t::rb_io_enc_t::ecflags   stored    right   before
     * initialising ::rb_io_t::writeconv.
     */
    int writeconv_pre_ecflags;

    /**
     * Value of ::rb_io_t::rb_io_enc_t::ecopts stored right before initialising
     * ::rb_io_t::writeconv.
     */
    VALUE writeconv_pre_ecopts;

    /**
     * This is a Ruby  level mutex.  It avoids multiple threads  to write to an
     * IO at  once; helps  for instance rb_io_puts()  to ensure  newlines right
     * next to its arguments.
     *
     * This of course doesn't help inter-process IO interleaves, though.
     */
    VALUE write_lock;

    /**
     * The timeout associated with this IO when performing blocking operations.
     */
    VALUE timeout;
};
```
