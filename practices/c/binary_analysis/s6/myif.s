# はじめて学ぶバイナリ解析 不正なコード型コンピュータを守るサイバーセキュリティ技術

global main

main:
mov  eax, 0x5
cmp  eax, 0x3
jz   equal
jmp  neq

equal:
mov  eax, 0x1
jmp  exit

neq:
mov eax, 0x0

exit:
