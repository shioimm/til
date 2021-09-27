# 独習アセンブラ
    .text
    .global _start

_start:
    movq    vec1,   %mm0

    pmaddwd vec2,   %mm0

    movq    %mm0,   %mm1
    psrlq   $32,    %mm1
    paddd   %mm1,   %mm0

    movl    $1,     %eax
    int     $0x80

    .data
    .align
vec1:  .word 1, 2, 3, 4
vec2:  .word 5, -6, 7, 8
