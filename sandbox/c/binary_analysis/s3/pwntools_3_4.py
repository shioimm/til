# はじめて学ぶバイナリ解析 不正なコード型コンピュータを守るサイバーセキュリティ技術
from pwn import *

p = process("./a.out")
p.sendfile("\x01\x02\x03\x04\x05")
print(p.recvline())
