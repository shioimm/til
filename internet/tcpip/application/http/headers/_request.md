# Request
## Accept
- [Accept](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Accept)
- クライアントが受け付けるMIMEタイプ(コンテントネゴシエーション)

## Accept-Language
- [Accept-Language](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Accept-Language)
- クライアントが受け付ける表示言語(コンテントネゴシエーション)

## Accept-Encoding
- [Accept-Encoding](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Accept-Encoding)
- クライアントが受け付けるボディの圧縮アルゴリズム(コンテントネゴシエーション)

## Accept-Charset
- 参照: [Accept-Charset](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Accept-Charset)
- クライアントが受け付ける文字のキャラクターセット(コンテントネゴシエーション)
- モダンブラウザでは全キャラクラーセットのエンコーダーが内包されているため送信されていない

## Authorization
- [Authorization](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Authorization)
- 認証が要求されるページに送信される認証情報

## Cookie
- [Cookie](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Cookie)
- サーバーから設定されたCookieのパラメータ

## Host
- [Host](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Host)
- リクエスト先のホスト・ポート番号

## If-Modified-Since
- [If-Modified-Since](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/If-Modified-Since)
- 条件付リクエストに使用する
- 最後に取得した時刻以降に更新がある場合、リソースを再要求する

## If-None-Match
- [If-None-Match](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/If-None-Match)
- 条件付リクエストに使用する
- 指定したETagのバージョン以降に更新がある場合、リソースを再要求する

## Range
- 引用: Webを支える技術 山本陽平・著
- [Range](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Range)
- 部分的GETでリソースの一部を取得する際、バイト単位で示される取得の範囲
- 一つのRangeヘッダーで複数の部分を一度に要求でき、
  サーバーは範囲をマルチパートドキュメントで送り返すことができる

## Referer
- [Referer](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Referer)
- リンク元のURLを示す
- URLが秘密情報(セッションID)を含んでいる場合、脆弱性になりうる

## Referrer-Policy
- [Referrer-Policy](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Referrer-Policy)
- Refererの情報をリクエストにどれだけ含めるかを制御する

## User-Agent
- [User-Agent](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/User-Agent)
- クライアントを表す識別子

## 参照
- よくわかるHTTP/2の教科書P29/38-39/41
- Real World HTTP 第2版
