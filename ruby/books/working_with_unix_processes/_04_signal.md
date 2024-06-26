# なるほどUNIXプロセス まとめ04
- Jesse Storimer 著
- 島田浩二・角谷信太郎 翻訳

## Chapter16
- waitはブロッキング呼び出し
  - 親プロセスは子プロセスが終了するまで処理を続行できない
- 親プロセスは、:CHLDシグナルを捕捉することで子プロセスの終了を検知できる
  - > シグナルとは、実行中のプロセスに対して、さまざまなイベントを通知するために送出されるものである。
    - from https://shellscript.sunone.me/signal_and_trap.html
  - シグナルの配信は信用できない
    - CHLDシグナルの処理中に別の子プロセスが終了した場合、次のCHLDシグナルを捕捉できる保証はない
    - waitの呼び出しをループさせて、全ての子プロセスの終了通知を待ち受ける必要がある

```
Process.#wait(pid, Process::WNOHANG) -> 終了を待つ子プロセスが存在しない場合、親プロセスの処理をブロックしない
第二引数に定数Process::WNOHANGを渡す
```

- 終了を待つ子プロセスがない状態でwaitするとErrno::ECHILD例外が送出される
  - CHLDシグナルのハンドラではErrno::ECHILD例外を捕捉する必要がある

### シグナルの手引き
- プロセスはカーネルからシグナルを受けたとき、いずれかの処理を行なう
  - シグナルを無視する
  - 特定の処理を行なう
  - デフォルトの処理を行なう
- シグナルには送信元がある
  - シグナルはある特定のプロセスから別のプロセスへ、カーネルを介して送られる
  - プロセスには各シグナルを受信した際のデフォルトの動作がある

#### 例
- `rails c`コマンドを実行
- コンソールが起動する前にCtrl + C
- シグナルSIGINT(キーボードによる中止)を検出してプロセスが終了する

### シグナルの再定義
```
Kernel.#trap <-> sigaction(2)
引数でシグナル名、ブロックでシグナルハンドラを渡すことでシグナルの動作を再定義できる
※:KILLシグナルは再定義できない
※シグナルハンドラに'IGNORE'を渡すとシグナルを無視できる
```
```
Process.#kill <-> kill(2)
指定されたプロセスにシグナルを送る
```
- シグナルはグローバルに動作する
- プロセスはいつでもシグナルを受信できる
  -  プロセスはシグナルを受信するとすぐにシグナルハンドラを実行する
