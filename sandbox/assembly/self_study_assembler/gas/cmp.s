# 独習アセンブラ
    .global _start
    .text
_start:
    movl  $123,%eax
    cmpl  $456,%eax
    je    L1            # 上の計算式が真ならL1へジャンプ / 偽なら下の行を計算
    movl  $msg_neq,%ecx # ECXにmsg_neqのアドレスを格納
    movl  $10,%edx      # EDXに10文字分のアドレス空間を確保
    jmp   L2            # L2へジャンプ
L1:
    movl  $msg_eq,%ecx  # ECXにmsg_eqのアドレスを格納
    movl  $6,%edx       # EDXに6文字分のアドレス空間を確保
L2:
    movl  $4,%eax       # EAXにシステムコール4番(write)を格納
    movl  $1,%ebx       # EBXに標準出力を格納
    int   $0x80
                        # システムコール4番(write)は
                        # EBXにファイルディスクリプタ、
                        # ECXに文字列の格納されたアドレス、
                        # EDXに文字列の長さが必要

    movl  $1,%eax
    int   $0x80

    .data # dataセクションを開始
msg_eq: .ascii  "equal\n"
msg_neq: .ascii  "not equal\n"
