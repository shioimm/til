# コネクション
- 参照: [普及が進む「HTTP/2」の仕組みとメリットとは](https://knowledge.sakura.ad.jp/7734/)
- 参照: [HTTP の進化](https://developer.mozilla.org/ja/docs/Web/HTTP/Basics_of_HTTP/Evolution_of_HTTP)
- 参照: [そろそろ知っておきたいHTTP/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- 参照: [Request and Response](https://youtu.be/0cmXVXMdbs8)
- 参照: [HTTP/2とは](https://www.nic.ad.jp/ja/newsletter/No68/0800.html)
- 参照: [HTTP/2](https://hpbn.co/http2/#binary-framing-layer)
- 参照: よくわかるHTTP/2の教科書P76-126

## コネクションの接続
- まずHTTP/1.1以前と同じ方法でクライアントからサーバーへ接続を行い、サーバーが対応していればHTTP/2に移行する
- クライアント -> サーバーへHTTP/2での通信開始をネゴシエーションする
  - リクエストと同時にConnectionヘッダ、Upgradeヘッダ、HTTP2-Settingsヘッダをリクエストヘッダとして送信する
  - サーバーはステータスコード101のレスポンスを返し、HTTP/2コネクションに移行
  - [HTTPSの場合]ALPN(TLS拡張)を使用する
  - [HTTPの場合]HTTP/1.1 -> HTTP/2へのアップグレード
  - [接続済の場合など]ダイレクトで開始する

## コネクションの再利用
- [HTTPの場合]ドメイン名のIPアドレスが同じ場合再利用可
- [HTTPSの場合]ドメイン名のIPアドレスが同じであり、 証明書が有効である場合再利用化
