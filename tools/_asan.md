# ASan (AddressSanitizer)

```
# (Ubuntu)
# Clangをインストール済み
$ clang --version

Ubuntu clang version 17.0.6 (++20231209124227+6009708b4367-1~exp1~20231209124336.77)
Target: x86_64-pc-linux-gnu
Thread model: posix
InstalledDir: /usr/lib/llvm-17/bin
```

```
# libclang_rt.asan-***.soとllvm-symbolizerのパスを確認
$ find /usr/lib/llvm-17/ | grep "libclang_rt.asan"
$ find /usr/bin/ | grep "llvm-symbolizer"
```

```
# .zshrc
export ASAN_SYMBOLIZER_PATH=$(which llvm-symbolizer)
export ASAN_OPTIONS=detect_leaks=1:abort_on_error=1:symbolize=1
```

```
$ cat test.c
#include <stdio.h>
#include <stdlib.h>

int main() {
    int *ptr = (int *)malloc(sizeof(int));
    free(ptr);
    *ptr = 42;  // 解放済みメモリへのアクセス
    return 0;
}

$ clang -fsanitize=address -o test test.c && ./test
=================================================================
==784184==ERROR: AddressSanitizer: heap-use-after-free on address 0x502000000010 at pc 0x5aa4eafbc0e3 bp 0x7ffe91539cb0 sp 0x7ffe91539ca8
WRITE of size 4 at 0x502000000010 thread T0
    #0 0x5aa4eafbc0e2 in main (/home/shioimm/shioimm/ruby/test+0x1040e2) (BuildId: 95e2439e693feb766f3d887dbc43bc5139d9ba57)
    #1 0x7e563de29d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    #2 0x7e563de29e3f in __libc_start_main csu/../csu/libc-start.c:392:3
    #3 0x5aa4eaee32e4 in _start (/home/shioimm/shioimm/ruby/test+0x2b2e4) (BuildId: 95e2439e693feb766f3d887dbc43bc5139d9ba57)

0x502000000010 is located 0 bytes inside of 4-byte region [0x502000000010,0x502000000014)
freed by thread T0 here:
    #0 0x5aa4eaf7f3e6 in free (/home/shioimm/shioimm/ruby/test+0xc73e6) (BuildId: 95e2439e693feb766f3d887dbc43bc5139d9ba57)
    #1 0x5aa4eafbc0a5 in main (/home/shioimm/shioimm/ruby/test+0x1040a5) (BuildId: 95e2439e693feb766f3d887dbc43bc5139d9ba57)
    #2 0x7e563de29d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16

previously allocated by thread T0 here:
    #0 0x5aa4eaf7f68e in malloc (/home/shioimm/shioimm/ruby/test+0xc768e) (BuildId: 95e2439e693feb766f3d887dbc43bc5139d9ba57)
    #1 0x5aa4eafbc098 in main (/home/shioimm/shioimm/ruby/test+0x104098) (BuildId: 95e2439e693feb766f3d887dbc43bc5139d9ba57)
    #2 0x7e563de29d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16

SUMMARY: AddressSanitizer: heap-use-after-free (/home/shioimm/shioimm/ruby/test+0x1040e2) (BuildId: 95e2439e693feb766f3d887dbc43bc5139d9ba57) in main
Shadow bytes around the buggy address:
  0x501ffffffd80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x501ffffffe00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x501ffffffe80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x501fffffff00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x501fffffff80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
=>0x502000000000: fa fa[fd]fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x502000000080: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x502000000100: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x502000000180: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x502000000200: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x502000000280: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07
  Heap left redzone:       fa
  Freed heap region:       fd
  Stack left redzone:      f1
  Stack mid redzone:       f2
  Stack right redzone:     f3
  Stack after return:      f5
  Stack use after scope:   f8
  Global redzone:          f9
  Global init order:       f6
  Poisoned by user:        f7
  Container overflow:      fc
  Array cookie:            ac
  Intra object redzone:    bb
  ASan internal:           fe
  Left alloca redzone:     ca
  Right alloca redzone:    cb
==784184==ABORTING
[1]    784184 IOT instruction (core dumped)  ./test
```
