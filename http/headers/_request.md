# Request
## プリフライトリクエストに使用されるヘッダ
- Access-Control-Request-Method - 通信を許可してもらいたいメソッドのリスト
- Access-Control-Request-Headers - 通信を許可してもらいたいリクエストヘッダのリスト
- Origin - 通信元のWebページのドメイン名

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

## ETag
- [ETag](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/ETag)
- 条件付リクエストに使用する
- 指定のエンティティタグと一致しない場合、リソースを再要求する
- Last-Modifiedの方が優先される

### 強い検証と弱い検証
- 強い検証 - 一文字も変更がないことを保証する
- 弱い検証 - データとしては別物でも内容的に同一であることを保証する
  - エンティティタグの先頭に`W/`がつく

## Host
- [Host](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Host)
- リクエスト先のホスト・ポート番号

## Last-Modified
- 条件付リクエストに使用する
- 最終更新日以降更新がある場合、リソースを再要求する
- ETagの方が優先される

### If-Modified-Since
- [If-Modified-Since](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/If-Modified-Since)
- 最後に取得した時刻以降に更新がある場合、リソースを再要求する

### If-None-Match
- [If-None-Match](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/If-None-Match)
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
