# Webサーバー
## アーキテクチャ
- 参照: [2015年Webサーバアーキテクチャ序論](https://blog.yuuk.io/entry/2015-webserver-architecture)
- Webサーバーにおけるアーキテクチャ = 並行処理の手法
  - シリアルモデル -> 並行処理を行わない
  - マルチプロセス -> リクエスト毎にforkし、生成した子プロセスによってリクエスト処理を行う
    - prefork -> サーバ起動時に予め生成しておいた子プロセス(ワーカープロセス)を使い回す
  - マルチスレッド ->  リクエスト毎にスレッドを生成し、生成したスレッドによってリクエスト処理を行う
    - スレッドプール -> サーバ起動時に予め生成しておいたスレッドを使い回す
  - イベント駆動 -> I/Oの多重化により、どのソケットからI/Oがあるかを知ることにより複数のネットワークI/Oを捌けるようにする
  - ハイブリッド
    - マルチプロセス / スレッド -> イベント駆動
    - イベント駆動 -> マルチプロセス / スレッド

### prefork型サーバー
- 参照: [キャッシュしたデータが消える!?prefork型HTTPサーバーUnicornでドはまりしたメモ](http://unageanu.hatenablog.com/entry/20150214/1423893247)
- 参照: [Why Ruby app servers break on macOS High Sierra and what can be done about it](https://blog.phusion.nl/2017/10/13/why-ruby-app-servers-break-on-macos-high-sierra-and-what-can-be-done-about-it/)
- HTTPリクエストをメインプロセスからforkした子プロセスで処理するHTTPサーバー
  - Puma、Unicorn、Passenger

#### prefork機能
- アプリケーションコードをサーバー自身のメインプロセス内にロードし、fork時にOSに対してコピーする
  - ただし仮想メモリを実装するOSは元のプロセスのメモリを即時コピーしない
  - 元のプロセスまたは子プロセスがそのメモリを変更しようとした瞬間にのみコピーされる
  - 変更されたメモリ領域だけがコピーされ、メモリ領域全体はコピーされない
    - プロセスをforkすると、fork()を呼び出したスレッド以外が消える
    - forkした時点で他のスレッドが矛盾した状態になっている可能性がある -> メモリを直接読み取り・変更するコードが壊れる可能性がある
    - MacOS HighSierraより後のOSは、gemの依存関係によってはこの挙動により即時クラッシュする
      - シェルに`export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES`の設定が必要
    - Ruby公式の回避策はまだ無い(2019/12/11)
- Puma -> cluster mode、Unicorn -> preload_app、Passenger -> smart spawning

## HTTP/2対応
### サーバーの接続形態
- 参照: よくわかるHTTP/2の教科書P64-65
- (a)HTTP/2を直接受ける
```
クライアント -> HTTP/2 -> サーバー
```
- (b)HTTP/2をリバースプロキシする
```
クライアント -> HTTP/2 -> プロキシサーバー -> HTTP/2 -> バックエンドサーバー
クライアント -> HTTP/2 -> プロキシサーバー -> HTTP/1 -> バックエンドサーバー
```
- (c)TLSの終端のみ行う
```
クライアント -> HTTP/2 over TLS -> TLS終端サーバー -> HTTP/2 -> バックエンドサーバー
```
