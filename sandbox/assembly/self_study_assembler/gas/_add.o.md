```
$ as -a -o add.o add.s
GAS LISTING add.s 			page 1


   1              	    .global _start
   2              	    .text
   3              	_start:
   4 0000 B80C0000 	    movl  $12,%eax
   5      00
   5 0005 83C022   	    addl  $34,%eax
   6
   7 0008 89C3     	    movl  %eax,%ebx
   8 000a B8010000 	    movl  $1,%eax
   9      00
   9 000f CD80     	    int   $0x80

GAS LISTING add.s 			page 2


DEFINED SYMBOLS
               add.s:4      .text:0000000000000000 _start

NO UNDEFINED SYMBOLS
```

```
$ ls -l add.o
-rw-r--r-- 1 root root 712 Sep 19 01:27 add.o
$ file add.o
add.o: ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), not stripped
```

```
# objdump -d add.o

add.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <_start>:
   0:	b8 0c 00 00 00       	mov    $0xc,%eax
   5:	83 c0 22             	add    $0x22,%eax
   8:	89 c3                	mov    %eax,%ebx
   a:	b8 01 00 00 00       	mov    $0x1,%eax
   f:	cd 80                	int    $0x80
```

```
$ objdump -t add.o

add.o:     file format elf64-x86-64

SYMBOL TABLE:
0000000000000000 l    d  .text	0000000000000000 .text
0000000000000000 l    d  .data	0000000000000000 .data
0000000000000000 l    d  .bss	0000000000000000 .bss
0000000000000000 g       .text	0000000000000000 _start
```

```
$ ld -o add add.o
$ ls -l add
-rwxr-xr-x 1 root root 4648 Sep 19 01:34 add

$ file add
add: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped

$ ./add
$ echo $?
46
```

## 参照
- 独習アセンブラ
