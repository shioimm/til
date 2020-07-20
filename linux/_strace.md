# straceコマンド
- 参照: [Strace](https://wiki.ubuntu.com/Strace)

## TL;DR
- システムコールをトレースし、ログに記録するユーティリティコマンド

## Getting Started
```
$ apt-get install strace
```

## Usage
```
$ strace ps

execve("/bin/ps", ["ps"], 0x7ffdf552e3d0 /* 21 vars */) = 0
brk(NULL)                               = 0x55cd50b6a000
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=26608, ...}) = 0
mmap(NULL, 26608, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f215beeb000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libprocps.so.6", O_RDONLY|O_CLOEXEC) = 3
# ...
```
