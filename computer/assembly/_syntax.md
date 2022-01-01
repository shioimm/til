# 文法
```asm
    .擬似命令 シンボル
ラベル:
    命令  シンボル, 引数
```

```asm
    .global _start
    .text
_start:
    movl  $123,     %eax
    cmpl  $456,     %eax
    je    L1
    movl  $msg_neq, %ecx
    movl  $10,      %edx
    jmp   L2
L1:
    movl  $msg_eq,  %ecx
    movl  $6,       %edx
L2:
    movl  $4,       %eax
    movl  $1,       %ebx
    int   $0x80

    movl  $1,       %eax
    int   $0x80

    .data
msg_eq:  .ascii  "equal\n"
msg_neq: .ascii  "not equal\n"
```

## 参照
- 独習アセンブラ
