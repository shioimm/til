# リアルタイムシグナル
- 参照: Linuxプログラミングインターフェース 22章

## TL;DR
- 標準シグナルに内在する制限を克服するべく導入された機構

### 標準シグナルとの比較
- アプリケーションが自由に使用できるシグナルの種類が多い
  - 標準シグナルは`SIGUSR1` / `SIGUSR2`のみ
- 同じ種類のシグナルが複数回送信された場合、シグナルがキューイングされる
  - カーネルはプロセス毎にリストを用意しリアルタイムシグナルを管理する
  - `SIGQUEUE_MAX`数分のシグナルをキューすることができる
  - 標準シグナルは保留中のシグナルが何度送信されてもプロセスが受信できるのは一回のみ
- 送信時にデータを付加できる(整数 / ポインタ)
- 異なる種類のリアルタイムシグナルの受信順序が保障される(シグナル番号昇順)

## リアルタイムシグナルの種類
- 32種類(シグナル番号32 - 64)
  - `SIGRTMAX` - リアルタイムシグナル番号の上限(`<limits.h>`)
  - `SIGRTMIN` - リアルタイムシグナル番号の下限(`<limits.h>`)
    - Ex. `SIGRTMIN` + 1 = 2番目のリアルタイムシグナル

## リアルタイムシグナルの送信
- `sigqueue(3)`を使用してシグナルを付加データとともに送信する

## リアルタイムシグナルの受信
- `sigaction(2)`を使用して`SA_SIGINFO`フラグをセットしたシグナルハンドラを設定する
  シグナルハンドラには付加データも渡される
