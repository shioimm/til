# 独習アセンブラ
    .text
    .global _start

_start:
    movq    string, %mm0

    pxor    %mm1, %mm1
    pcmpeqb %mm0, %mm1

    packsswb %mm1, %mm1
    movd     %mm1, %eax

    movl    $1,    %eax
    int     $0x80

    .data
    .align
string:
    .asciz "Hello"
    .byte  0xff
