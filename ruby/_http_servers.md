## prefork型HTTPサーバー
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
