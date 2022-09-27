# objdump(1)
- オブジェクトファイルの情報を表示する

#### アーカイブファイルの内容を表示

```
$ objdump -a <FileName>.a
```

#### オブジェクトファイルの逆アセンブル情報を表示

```
$ objdump -d <FileName>.o
```

- 左からメモリ空間の位置情報を表すアドレス、マシン語命令、アセンブリ言語命令

```
$ objdump -d add.o

add.o:     file format elf64-x86-64
Disassembly of section .text:
0000000000000000 <_start>:
   0: b8 0c 00 00 00        mov    $0xc,%eax
   5: 83 c0 22              add    $0x22,%eax
   8: 89 c3                 mov    %eax,%ebx
   a: b8 01 00 00 00        mov    $0x1,%eax
   f: cd 80                 int    $0x80
```
