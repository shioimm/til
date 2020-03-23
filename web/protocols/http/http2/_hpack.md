# HPACK
- 参照: [普及が進む「HTTP/2」の仕組みとメリットとは](https://knowledge.sakura.ad.jp/7734/)
- 参照: [HTTP の進化](https://developer.mozilla.org/ja/docs/Web/HTTP/Basics_of_HTTP/Evolution_of_HTTP)
- 参照: [そろそろ知っておきたいHTTP/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- 参照: [Request and Response](https://youtu.be/0cmXVXMdbs8)
- 参照: [HTTP/2 Server Pushとは？(CDN サーバープッシュでWeb高速化）](https://blog.redbox.ne.jp/http2-server-push-cdn.html)
- 参照: [HTTP/2とは](https://www.nic.ad.jp/ja/newsletter/No68/0800.html)
- 参照: [HTTP/2](https://hpbn.co/http2/#binary-framing-layer)
- 参照: よくわかるHTTP/2の教科書P76-126

## HPACK
- ハフマン符号とインデックステーブルの組み合わせでヘッダを圧縮し、
  作成したヘッダをHEADERSフレームに格納して送信する

### ハフマン符号
- 出現頻度の高い文字を短いbit数で示す

### インデックステーブル
- ヘッダ名とヘッダ値を格納する辞書テーブル
- 静的テーブル -> 事前に定義
- 動的テーブル -> 送信したヘッダを動的に追加
