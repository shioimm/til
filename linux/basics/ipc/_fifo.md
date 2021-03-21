# FIFO(名前付きパイプ)
- 参照: 例解UNIX/Linuxプログラミング教室P257-289
- 参照: 詳解UNIXプログラミング第3版 15. プロセス間通信
- 参照: Linuxネットワークプログラミング Chapter7 プロセス間通信 7-7
- 参照: Linuxによる並行プログラミング入門 第4章 リダイレクトとパイプ 4.5
- 参照: Linuxプログラミングインターフェース 44章

## TL;DR
- FIFOは任意のプロセス間で通信可能
- FIFOはファイルディスクリプタが全てクローズされても存続する
- UnixのファイルシステムにおいてFIFOはファイルとして扱われる

## 作成
- `mkfifo(2)` / `mkfifoat(2)` - FIFOの作成

## 通信
- シェルの一つのパイプラインから別のパイプラインへデータを渡す

```
Ex.

infile
  |
prog1
  |
tee - prog2
    |
    |- fifo - prog3
```

```
$ mkfifo fifo
$ prog3 < fifo &
$ prog1 < infile | tee fifo | prog2
```

- クライアント - サーバーシステムにおけるデータの待ち合わせ場所(ランデブー場所)とする

```
client1  ←   送信FIFO1
   ↓           ↑
  受信FIFO → server
   ↑           ↓
client2  ←   送信FIFO2
```
