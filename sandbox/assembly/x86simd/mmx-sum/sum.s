# 独習アセンブラ
    .text
    .global _start

_start:
    movq    vec,   %mm0

    movq    %mm0,  %mm1
    psrlq   $32,   %mm1
    paddb   %mm1,  %mm0

    movq    %mm0,  %mm1
    psrlq   $16,   %mm1
    paddb   %mm1,  %mm0

    movq    %mm0,  %mm1
    psrlq   $8,    %mm1
    paddb   %mm1,  %mm0

    movl    $1,    %eax
    int     $0x80

     .data
     .align 16
vec: .byte   1, 2, 3, 4, 5, 6, 7, 8
