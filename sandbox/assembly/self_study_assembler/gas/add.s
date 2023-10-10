# 独習アセンブラ
    .global _start  # 大域的なシンボル_startを定義
    .text           # .textセクションを開始
_start:             # 以降は_startの実体
    movl  $12,%eax  # EAXに12を格納
    addl  $34,%eax  # EAXに34を追加

    movl  %eax,%ebx # EAXの値をEBX(終了ステータスを受け取るレジスタ)へコピー
    movl  $1,%eax   # EAX(システムコールの値を格納するレジスタ)にシステムコール1番(exit)を格納
    int   $0x80     # 0x80番のソフトウェア割り込み(システムコールを実行する)を発生させる

# オブジェクトファイルにアセンブル
# $ as -a -o add.o add.s
# オブジェクトファイルをリンクして実行ファイルを作成
# $ ld -o add add.o
