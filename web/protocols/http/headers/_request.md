# Request
- 参照: よくわかるHTTP/2の教科書P29

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

## Content-Length
- 参照: [Content-Length](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Length)
- POSTするデータ長

## Cookie
- 参照: [Cookie](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Cookie)
- 参照: [サードパーティクッキーって何だっけ？ 今さら聞けないHTTP Cookieのキホン](https://webtan.impress.co.jp/e/2017/10/03/27016)
- HTTPにおける状態管理の仕組み
  - ファーストパーティCookie -> 表示中のHTMLと同じサーバーから送信されたCookie
  - サードパーティCookie -> 表示中のHTMLとは別のサーバーから送信されたCookie
- ブラウザの状態を継続的に管理するための情報を保存するためのストレージ
- Cookieはリソースが送信されたサーバー(origin)と紐づく

## Host
- 参照: [Host](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Host)
- リクエスト先のホスト・ポート番号

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
