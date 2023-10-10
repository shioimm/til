# はじめて学ぶバイナリ解析 不正なコード型コンピュータを守るサイバーセキュリティ技術
from pwn import *

shellcode = asm("push 0x00006948; mov eax, 0x4; mov ebx, 0x1; mov ecx, esp; mov edx, 0x4; int 0x80")
print(enhex(shellcode))
