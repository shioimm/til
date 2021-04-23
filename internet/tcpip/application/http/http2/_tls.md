# HTTP/2とTLS
- 参照: [普及が進む「HTTP/2」の仕組みとメリットとは](https://knowledge.sakura.ad.jp/7734/)
- 参照: [HTTP の進化](https://developer.mozilla.org/ja/docs/Web/HTTP/Basics_of_HTTP/Evolution_of_HTTP)
- 参照: [そろそろ知っておきたいHTTP/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- 参照: [Request and Response](https://youtu.be/0cmXVXMdbs8)
- 参照: [HTTP/2 Server Pushとは？(CDN サーバープッシュでWeb高速化）](https://blog.redbox.ne.jp/http2-server-push-cdn.html)
- 参照: [HTTP/2とは](https://www.nic.ad.jp/ja/newsletter/No68/0800.html)
- 参照: [HTTP/2](https://hpbn.co/http2/#binary-framing-layer)
- 参照: よくわかるHTTP/2の教科書P76-126

## セキュリティ
- HTTP/2においてTLSを使用する場合の規約
  - TLS 1.2以上
  - SNI（Server Name Indication）をサポート
  - 仕様で指定される暗号スイートを使用
  - TLSの圧縮機能を無効化
  - TLSの再ネゴシエーションを使用しない
- 規約が守られない通信はHTTP/2レイヤでコネクションエラーが発生
