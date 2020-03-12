# Response
## Cookie
- 参照: [Cookie](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Cookie)
- 参照: [サードパーティクッキーって何だっけ？ 今さら聞けないHTTP Cookieのキホン](https://webtan.impress.co.jp/e/2017/10/03/27016)
- HTTPにおける状態管理の仕組み
  - ファーストパーティCookie -> 表示中のHTMLと同じサーバーから送信されたCookie
  - サードパーティCookie -> 表示中のHTMLとは別のサーバーから送信されたCookie
- ブラウザの状態を継続的に管理するための情報を保存するためのストレージ
- Cookieはリソースが送信されたサーバー(origin)と紐づく

### SameSite属性
- 現在のドメインから別のドメインに対してリクエストを送る際、Cookieを送信するかどうか
  - none -> Cookieを送信する
  - strict -> Cookieを設定したドメインに対してのみCookieを送信する
  - lax -> ドメイン間のサブリクエストと外部サイトのURL(ユーザーがリンクをたどった場合など)に送信する

### Secure属性
- Secure属性をつけたCookieはHTTPS通信時のみ送信されるようになる

### HttpOnly属性
- HttpOnly属性をつけたCookieはJavaScriptから参照できなくなる

### Content-Security-Policy
- 参照: [Content-Security-Policy](https://developer.mozilla.org/ja/docs/Web/HTTP/CSP)
```
Content-Security-Policy: 指定したいポリシー
```
- `script-src 'self'` -> クライアントが実行できるJSのソースを、サーバーと同一オリジンに限定する
  - 悪意のあるユーザーが投稿に別オリジンのスクリプトを埋め込んでも実行できないようにしてい
  - `script-src`ディレクティブに`nonce-ランダムな文字列`を指定することによって、
  同じnonce属性を持つscriptタグのみを実行するようになる

## Content-Security-Policy-Report-Only
- [Content-Security-Policy-Report-Only](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only)
- ポリシーの適用を行わず、指定したポリシーに反する内容を指定したURLに送信する
- `report-uri` -> 報告先のURIを指定する

## ETag
- 引用: Webを支える技術 山本陽平・著
- 参照: [ETag](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/ETag)
- リソースが更新された場合、新しい値を生成して返す
- 条件付きリクエストで条件を確認するために使用される
- 頭文字のW\は弱いETag値(バイト単位で同じリソースであることを保証しない)を示す

## Feature-Policy
- 参照: [https://developer.mozilla.org/ja/docs/Web/HTTP/Feature_Policy](https://developer.mozilla.org/ja/docs/Web/HTTP/Feature_Policy)
- 参照: [機能ポリシーの使用](https://developer.mozilla.org/ja/docs/Web/HTTP/Feature_Policy/Using_Feature_Policy)
- 参照: [Rails 6.1 adds HTTP Feature Policy](https://blog.saeloun.com/2019/10/01/rails-6-1-adds-http-feature-policy.html)
- Webサイト全体でどの機能が使用できるかを制御する役割を持っている
- Railsではconfig/initializers/feature_policy.rbに設定を置く(6.1以降)
  - controllerで機能ごとに設定を上書きすることもできる

## Referer
- 参照: [Referer](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Referer)
- リンク元のURLを示す
- URLが秘密情報(セッションID)を含んでいる場合、脆弱性になりう

## Strict-Transport-Security
- 参照: [Strict-Transport-Security](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Strict-Transport-Security)
- サイトからブラウザに対してHTTPではなくHTTPSを用いて通信を行うよう指示する

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
