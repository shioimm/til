# Request
- 参照: よくわかるHTTP/2の教科書P29/38-39/41

## Accept
- 参照: [Accept](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Accept)
- クライアントが受け付けるMIMEタイプ

## Accept-Language
- 参照: [Accept-Language](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Accept-Language)
- クライアントが受け付ける言語タイプ

## Accept-Encoding
- 参照: [Accept-Encoding](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Accept-Encoding)
- クライアントが受け付けるエンコーディングタイプ(圧縮アルゴリズム)

## Authorization
- 参照: [Authorization](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Authorization)
- 認証が要求されるページに送信される認証情報

## Connection
- 参照: [Connection](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Connection)
- トランザクション完了後もネットワーク接続を開いたままにするかどうかを制御

## Content-Length
- 参照: [Content-Length](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Length)
- POSTするデータ長

## Cookie
- 参照: [Cookie](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Cookie)
- サーバーから設定されたCookieのパラメータ

## Host
- 参照: [Host](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Host)
- リクエスト先のホスト・ポート番号

## If-Modified-Since
- 参照: [If-Modified-Since](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/If-Modified-Since)
- 条件付リクエストに使用する
- 最後に取得した時刻以降に更新がある場合、リソースを再要求する

## If-None-Match
- 参照: [If-None-Match](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/If-None-Match)
- 条件付リクエストに使用する
- 指定したETagのバージョン以降に更新がある場合、リソースを再要求する

## Range
- 引用: Webを支える技術 山本陽平・著
- 参照: [Range](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Range)
- 部分的GETでリソースの一部を取得する際、バイト単位で示される取得の範囲
- 一つのRangeヘッダーで複数の部分を一度に要求でき、
  サーバーは範囲をマルチパートドキュメントで送り返すことができる

## Referer
- 参照: [Referer](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Referer)
- リンク元のURLを示す
- URLが秘密情報(セッションID)を含んでいる場合、脆弱性になりうる

## User-Agent
- 参照: [User-Agent](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/User-Agent)
- クライアントを表す識別子
