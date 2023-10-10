# はじめて学ぶバイナリ解析 不正なコード型コンピュータを守るサイバーセキュリティ技術

global main

main:
push 0x00006948
mov  eax, 0x4
mov  ebx, 0x1
mov  ecx, esp
mov  edx, 0x4

# $ nasm -g -f elf32 hi.s
# $ gcc -m32 hi.o
