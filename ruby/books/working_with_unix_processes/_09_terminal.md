# なるほどUNIXプロセス まとめ09
- Jesse Storimer 著
- 島田浩二・角谷信太郎 翻訳

## Chapter19
- シェルアウト -> 端末から外部コマンドを動かす
  - fork(2) + execve(2)でシェルアウトを行う
    - execve(2) -> 現在のプロセスを別のプロセスに置き換える
      - 新しいプロセスは元のプロセスとメモリを共有しない
      - 現在のプロセスは終了する
    - fork(2)で新しく子プロセスを生成して、execve(2)で任意のプロセスに置き換える
      - -> 元のプロセスと別のプロセスを生成することができる

```
Kernel.#exec <-> execve(2)

指定されたコマンドを実行する
Kernel.#execはデフォルトで標準ストリーム以外のファイルディスクリプタを全て閉じるが、execve(2)は閉じない
外部コマンドを文字列で渡すと、シェルが起動して文字列を解釈する
配列として渡すと、シェルは起動せずにARGVとして新しいプロセスに渡す
```
```
Kernel.#system <-> system(3)

引数を外部コマンドとして実行し、終了コードが0ならtrue、それ以外ならfalseを返す
外部コマンド側の標準ストリームは現在のプロセスと共有される
```
```
Kernel#`

``で囲んだ文字列を外部コマンドとして実行し、STDOUTを文字列にした結果を返す
%x[]と同じ
```
```
Process.#spawn

引数を外部コマンドとして実行し、子プロセスのpidを返す
親プロセスの実行をブロックしない
```
```
IO.popen <-> popen(3)

引数を外部コマンドとして実行し、そのプロセスのSTDOUTとの間に生成したパイプをIO オブジェクトとして返す
```
```
open3 -> 引数を外部コマンドとして実行し、そのプロセスの標準入力・標準出力・ 標準エラー出力にパイプをつなぐ
```
