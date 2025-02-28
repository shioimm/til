# ldd(1)
- プログラムがリンクしているライブラリを表示する

```
$ ldd /usr/lib/apache2/modules/mod_mruby.so

  linux-vdso.so.1 (0x00007ffc3eda3000)
  libcrypto.so.1.1 => /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 (0x00007f35218fa000)
  libpthread.so.0  => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f35216db000)
  librt.so.1       => /lib/x86_64-linux-gnu/librt.so.1 (0x00007f35214d3000)
  libsqlite3.so.0  => /usr/lib/x86_64-linux-gnu/libsqlite3.so.0 (0x00007f35211ca000)
  libm.so.6        => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f3520e2c000)
  libc.so.6        => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f3520a3b000)
  libdl.so.2       => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f3520837000)
  /lib64/ld-linux-x86-64.so.2 (0x00007f3522185000)
```
