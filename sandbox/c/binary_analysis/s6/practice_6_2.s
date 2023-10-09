# はじめて学ぶバイナリ解析 不正なコード型コンピュータを守るサイバーセキュリティ技術

global main

main:
mov eax, 0x4
mov eax, 0x1
mov ecx, esp
mov edx, 0x4

# $ nasm -g -f elf32 hi_6_1.s
# $ gcc -m32 hi_6_1.o
