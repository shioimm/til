# ネットワーク
### ソケット
- 参照: [2015年Webサーバアーキテクチャ序論](https://blog.yuuk.io/entry/2015-webserver-architecture)
  - 引用: UNIXネットワークプログラミング 第２版 Vol.1 p43
- 参照: [「Working with TCP Sockets」を読んだ](https://blog.tsurubee.tech/entry/2018/07/25/152514)

- ソケットは通信におけるエンドポイントを表現したデータモデル
  - ソケットペアはコネクションの両方のエンドポイントを識別する
    - TCPコネクションはソケットペアによって一意に識別される
      - ローカルIPアドレス
      - ローカルTCPポート
      - リモートIPアドレス
      - リモートTCPポート
- ソケットはコネクションレスなネットワークプロトコルにも拡張できる

#### listener(サーバー)ソケット
- 1．create
- 2．bind -> createしたソケットとlistenするポートを結びつける
- 3．listen
- 4．accept -> クライアントソケットからの接続を受け付ける
  - acceptはブロッキング処理
  - 接続後もサーバソケットはそのまま残り、次の接続を待ち受ける
- 5．close

#### initiator(クライアント)ソケット
- 1．create
- (2．bind)
- 3．connect -> サーバーソケットへの接続を行う
- 4．close
