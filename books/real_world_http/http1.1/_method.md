# Real World HTTP 歴史とコードに学ぶインターネットとウェブ技術 まとめ
- 渋川よしき 著

## メソッド
### [OPTIONS](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/OPTIONS) -> HTTP/1.1で追加
- サーバーが受け取り可能なメソッド一覧を返す
- サーバー側で使用が許可されていない場合が多い

### [TRACE](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/TRACE) -> HTTP/1.1で追加
- サーバーが受け取るとContent-Typeにmessage/httpを設定し、ステータスコード200をつけてリクエストヘッダとボディを返す
- XST脆弱性により現在は使われていない

### [CONNECT](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/CONNECT) -> HTTP/1.1で追加
- HTTPのプロトコル上に他の他のプロトコルのパケットを流せるようにする
- プロキシサーバー経由でターゲットのサーバーに接続することを目的とする
- https通信を中継する用途で使われる
