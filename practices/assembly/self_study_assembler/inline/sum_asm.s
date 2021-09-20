# 独習アセンブラ
    .global sum_asm # 外部から呼び出し可能
    .text
sum_asm:
    movl    $0,         %eax
    movl    $array,     %edx # Cのソースコード側で大域変数として宣言したarray
    movl    array_size, %ecx # Cのソースコード側で大域変数として宣言したarray_sizeのアドレス
L1:
    add     (%edx),     %eax
    add     $4,         %edx
    loop    L1
    ret
