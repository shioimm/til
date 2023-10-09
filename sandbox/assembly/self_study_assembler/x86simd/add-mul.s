# 独習アセンブラ
      .text
      .global _start
_start:
    movdqa  vec1,  %xmm0
    movdqa  vec2,  %xmm1

    # 8個の16ビット整数を加算
    # xmm1 <- + xmm0
    paddw   %xmm0, %xmm1

    # 8個の16ビット整数を乗算し、下位16ビットを保存
    # xmm0 <- * xmm1
    pmullw  %xmm1, %xmm0

    movl    $1,    %eax # exit
    int     $0x80       # exit呼び出し

      .data
      .align 16
vec1: .word 0, 1, 2, 3, 4, 5, 6, 7     # 16ビット * 8
vec2: .word 1, -1, 2, -2, 3, -3, 4, -4 # 16ビット * 8

# $ as -a -o add-mul.o add-mul.s
# $ ld -o add_mul add-mul.o
