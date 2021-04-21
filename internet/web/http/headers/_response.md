# Response
- 参照: よくわかるHTTP/2の教科書P32/38-39/41

## Cache-Control
- 参照: [Cache-Control](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Cache-Control)
- クライアントがどのようにリソースをキャッシュするかを指定する

### ディレクティブ
- no-store -> リソースを保存してはいけない
- no-cache -> サーバーへの確認なしにリソースを保存してはいけない
- private -> リソースを受け取った本人だけがキャッシュできる
- public -> 複数のユーザーがリソースを再利用できる(キャッシュサーバーなどへの指示)
- max-age -> 有効期限(秒)だけキャッシュできる

## Connection
- 参照: [Connection](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Connection)
- トランザクション完了後もネットワーク接続を開いたままにするかどうかを制御

## Content-Security-Policy
- 参照: [Content-Security-Policy](https://developer.mozilla.org/ja/docs/Web/HTTP/CSP)
```
Content-Security-Policy: 指定したいポリシー
```
- `script-src 'self'` -> クライアントが実行できるJSのソースを、サーバーと同一オリジンに限定する
  - 悪意のあるユーザーが投稿に別オリジンのスクリプトを埋め込んでも実行できないようにしてい
  - `script-src`ディレクティブに`nonce-ランダムな文字列`を指定することによって、
  同じnonce属性を持つscriptタグのみを実行するようになる

## Content-Charset
- 参照: [Content-Charset](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Charset)
- コンテンツの文字のキャラクターセット(コンテントネゴシエーション)

## Content-Encoding
- 参照: [Content-Encoding](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Encoding)
- コンテンツのボディの圧縮アルゴリズム(コンテントネゴシエーション)

## Content-Language
- 参照: [Content-Language](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Language)
- コンテンツのボディの表示言語(コンテントネゴシエーション)

## Content-Length
- 参照: [Content-Length](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Length)
- コンテンツのデータ長
- 圧縮されている場合は圧縮後のデータサイズ

## Content-Type
- 参照: [Content-Type](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Type)
- コンテンツのMIMEタイプ(コンテントネゴシエーション)

## Content-Security-Policy-Report-Only
- [Content-Security-Policy-Report-Only](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only)
- ポリシーの適用を行わず、指定したポリシーに反する内容を指定したURLに送信する
- `report-uri` -> 報告先のURIを指定する

## Date
- 参照: [Date](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Date)
- リソースが生成された日時

## ETag
- 引用: Webを支える技術 山本陽平・著
- 参照: [ETag](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/ETag)
- リソースのバージョンを識別する
  - リソースが更新された場合、新しい値を生成して返す
  - 条件付きリクエストで条件を確認するために使用される
- 頭文字のW\は弱いETag値(バイト単位で同じリソースであることを保証しない)を示す

## Expires
- 参照: [Expires](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Expires)
- リソースの有効期限

## Feature-Policy
- 参照: [https://developer.mozilla.org/ja/docs/Web/HTTP/Feature_Policy](https://developer.mozilla.org/ja/docs/Web/HTTP/Feature_Policy)
- 参照: [機能ポリシーの使用](https://developer.mozilla.org/ja/docs/Web/HTTP/Feature_Policy/Using_Feature_Policy)
- 参照: [Rails 6.1 adds HTTP Feature Policy](https://blog.saeloun.com/2019/10/01/rails-6-1-adds-http-feature-policy.html)
- Webサイト全体でどの機能が使用できるかを制御する役割を持っている
- Railsではconfig/initializers/feature_policy.rbに設定を置く(6.1以降)
  - controllerで機能ごとに設定を上書きすることもできる

## Last-Modified
- 参照: [Last-Modified](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Last-Modified)
- リソースが最後に更新された日時

## Referer
- 参照: [Referer](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Referer)
- リンク元のURLを示す
- URLが秘密情報(セッションID)を含んでいる場合、脆弱性になりうる

## Server
- 参照: [Server](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Server)
- サーバーのソフトウェア(文字列)

## Set-Cookie
- 参照: [Set-Cookie](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Set-Cookie)
- クライアントにCookieを設定する

### Domain属性
- Cookieを送信するドメイン対象を指定する

### Expire属性
- Cookieの有効期限(日付)

### Path属性
- Cookieを送信するURLのパス対象を指定する

### Max-Age属性
- Cookieの有効期限(秒)

### SameSite属性
- 現在のドメインから別のドメインに対してリクエストを送る際、Cookieを送信するかどうか
  - none -> Cookieを送信する
  - strict -> Cookieを設定したドメインに対してのみCookieを送信する
  - lax -> ドメイン間のサブリクエストと外部サイトのURL(ユーザーがリンクをたどった場合など)に送信する

### Secure属性
- https通信時のみ送信する

### HttpOnly属性
- JavaScriptから参照できないようにする

## Strict-Transport-Security
- 参照: [Strict-Transport-Security](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Strict-Transport-Security)
- サイトからブラウザに対してHTTPではなくHTTPSを用いて通信を行うよう指示する

## Trailer
- 参照: [Trailer](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Trailer)
- メッセージボディの送信中に動的に生成される可能性のあるメタデータを提供するため、
  チャンク化されたメッセージの最後に追加のフィールドを含めることを送信者に対して許可する
```
Trailer: header-names
```

## Transfer-Encoding
- 参照: [Transfer-Encoding](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Transfer-Encoding)
- ペイロード本文をユーザーに転送するために使われる符号化方式を指定する
- 複数の方式を同時に採用することも可能
  - chunked
  - compress
  - deflate
  - gzip
  - identity
```
Transfer-Encoding: gzip, chunked
```

## Vary
- 引用: Webを支える技術 山本陽平・著
- サーバーがコンテントネゴシエーションを行えるヘッダを示す
  - コンテントネゴシエーション -> クライアントからAccept-\*ヘッダで指定された方式でサーバーがリソースを返すHTTPの機能
- Varyヘッダの値に基づいて複数の表現をキャッシュできる
- Varyに追加できるヘッダ
  - Accept -> メディアタイプ
  - Accept-Charset -> 文字エンコーディング
  - Accept-Encoding -> 圧縮方式
  - Accept-Language -> 自然言語

- 例
```
Vary: Accept-Encoding, Accept-Language
```
- このリソースは複数の圧縮方法と自然言語によって内容が変化する
  - 最初のレスポンスと2回目のレスポンスで圧縮方法や言語が変わっても、
  クライアントは最初のレスポンスのキャッシュを破棄せず、2回目のレスポンスの結果もキャッシュする
  - ヘッダに\*が指定された場合、コンテントネゴシエーションが行われてもレスポンスをキャッシュするべきではない
  - キャッシュキーはAccept-Encoding, Accept-Language
    - キャッシュキー -> 保存されたキャッシュエントリを識別するインデックス
      - リクエストが持っているキーとの比較によって、合致した場合に対応したオブジェクトが返される
      - 引用: https://cloud.google.com/cdn/docs/caching?hl=ja#cache-keys

## X-Content-Type-Options
- 参照: [X-Content-Type-Options](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/X-Content-Type-Options)
- Content-Typeで指定されたMIMEタイプをブラウザが変更しないことを指定する

## X-Frame-Options
- 参照: [X-Frame-Options](https://developer.mozilla.org/ja/docs/Web/HTTP/X-Frame-Options)
- ブラウザがページを`<frame>` `<iframe>` `<embed>` `<object>`の中に表示することを許可するかどうかを示す

## X-XSS-Protection
- 参照: [X-XSS-Protection](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/X-XSS-Protection)
-  IE/Chrome/Safariにおいて、クロスサイトスクリプティング (XSS) 攻撃を検出したときにページの読み込みを停止する
