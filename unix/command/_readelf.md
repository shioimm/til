# readelf(1)
- ELFファイルの各種情報を表示する

```
# ELFヘッダの表示
$ readelf -e <FileName> # -hオプションも同じ

# プログラムヘッダの表示
$ readelf -l <FileName>

# セクションヘッダの表示
$ readelf -S <FileName>

# セクションヘッダの表示
$ readelf -S <FileName>

# シンボルテーブルの表示
$ readelf -s <FileName>
```

```
$ ar xv /usr/lib/x86_64-linux-gnu/libc.a printf.o
$ readelf -e printf.o

ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              REL (Relocatable file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x0  # プログラムの開始アドレス
  Start of program headers:          0 (bytes into file)
  Start of section headers:          896 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           0 (bytes)
  Number of program headers:         0
  Size of section headers:           64 (bytes)
  Number of section headers:         11
  Section header string table index: 10

Section Headers:
# Name (セクション名), Address (メモリマップ開始アドレス), Offset (ファイル内オフセット), Size (サイズ)
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .text             PROGBITS         0000000000000000  00000040
       00000000000000c5  0000000000000000  AX       0     0     16
  [ 2] .rela.text        RELA             0000000000000000  000002d0
       0000000000000048  0000000000000018   I       8     1     8
  [ 3] .data             PROGBITS         0000000000000000  00000105
       0000000000000000  0000000000000000  WA       0     0     1
  [ 4] .bss              NOBITS           0000000000000000  00000105
       0000000000000000  0000000000000000  WA       0     0     1
  [ 5] .note.GNU-stack   PROGBITS         0000000000000000  00000105
       0000000000000000  0000000000000000           0     0     1
  [ 6] .eh_frame         PROGBITS         0000000000000000  00000108
       0000000000000038  0000000000000000   A       0     0     8
  [ 7] .rela.eh_frame    RELA             0000000000000000  00000318
       0000000000000018  0000000000000018   I       8     6     8
  [ 8] .symtab           SYMTAB           0000000000000000  00000140
       0000000000000138  0000000000000018           9     6     8
  [ 9] .strtab           STRTAB           0000000000000000  00000278
       0000000000000057  0000000000000000           0     0     1
  [10] .shstrtab         STRTAB           0000000000000000  00000330
       0000000000000050  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  l (large), p (processor specific)

There are no program headers in this file.
```
