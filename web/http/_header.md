# Header
### Feature-Policy
- 参照: [https://developer.mozilla.org/ja/docs/Web/HTTP/Feature_Policy](https://developer.mozilla.org/ja/docs/Web/HTTP/Feature_Policy)
- 参照: [機能ポリシーの使用](https://developer.mozilla.org/ja/docs/Web/HTTP/Feature_Policy/Using_Feature_Policy)
- 参照: [Rails 6.1 adds HTTP Feature Policy](https://blog.saeloun.com/2019/10/01/rails-6-1-adds-http-feature-policy.html)
- レスポンスヘッダに含まれる(iframeの`allow`属性で設定することもできる)
- Webサイト全体でどの機能が使用できるかを制御する役割を持っている
- Railsではconfig/initializers/feature_policy.rbに設定を置く(6.1以降)
  - controllerで機能ごとに設定を上書きすることもできる

### Vary
- from Webを支える技術 山本陽平・著
- レスポンスヘッダに含まれる
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
      - from https://cloud.google.com/cdn/docs/caching?hl=ja#cache-keys

### ETag
- from Webを支える技術 山本陽平・著
- 参照: [ETag](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/ETag)
- レスポンスヘッダに含まれる
- リソースが更新された場合、新しい値を生成して返す
- 条件付きリクエストで条件を確認するために使用される
- 頭文字のW\は弱いETag値(バイト単位で同じリソースであることを保証しない)を示す

### Range
- from Webを支える技術 山本陽平・著
- リクエストヘッダに含まれる
- 部分的GETでリソースの一部を取得する際、バイト単位で示される取得の範囲

### Cookie
- 参照: [Cookie](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Cookie)
- 参照: [サードパーティクッキーって何だっけ？ 今さら聞けないHTTP Cookieのキホン](https://webtan.impress.co.jp/e/2017/10/03/27016)
- HTTPにおける状態管理の仕組み
  - ファーストパーティCookie -> 表示中のHTMLと同じサーバーから送信されたCookie
  - サードパーティCookie -> 表示中のHTMLとは別のサーバーから送信されたCookie
- ブラウザの状態を継続的に管理するための情報を保存するためのストレージ
- Cookieはリソースが送信されたサーバー(origin)と紐づく
