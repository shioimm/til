# 独習アセンブラ
    .global _start
    .text
_start:
    movl  $1,%eax   # CPUの情報・機能ビットを取得
    cpuid           # CPU IDentification
    movl  %edx,%ebx # EDXの値をEBXにコピー
    shrl  $24,%ebx  # 24ビット右シフト
    movl  $1,%eax
    int   $0x80

# $ as -o cpuid.o cpuid.s
# $ ld -o cpuid cpuid.o
# $ ./cpuid
# $ echo $?
# 159(EDXの値の上位8ビットの値: 10011111)
