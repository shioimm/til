# 独習アセンブラ
    .text
    .global _start

_start:
    movapd  x,     %xmm0

    mulpd   %xmm0, %xmm0
    haddpd  %xmm0, %xmm0

    sqrtpd  %xmm0, %xmm0

    movsd   %xmm0, dist

    movl    $1,    %eax
    int     $0x80

      .data
dist: .double 0
      .align  16
x:    .double 1.23
y:    .double -4.56
