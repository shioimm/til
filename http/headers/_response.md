# Response
#### Accept-Ranges
- クライアントが受け入れることができるMIMEタイプ

#### Age
- オリジンサーバーのリソースがプロキシサーバーにキャッシュされた後の経過時間 (秒)

#### Content-Disposition
- レスポンスがブラウザに表示するためのもの(`inline`)か、
  ダウンロードしてローカルに保存するためのもの(`attachment`)かを示す

#### Content-Security-Policy
- Webサイトで使える機能を細かくON/OFFする

```
Content-Security-Policy: 指定したいポリシー
```
- `script-src 'self'` -> クライアントが実行できるJSのソースを、サーバーと同一オリジンに限定する
  - 悪意のあるユーザーが投稿に別オリジンのスクリプトを埋め込んでも実行できないようにしてい
  - `script-src`ディレクティブに`nonce-ランダムな文字列`を指定することによって、
  同じnonce属性を持つscriptタグのみを実行するようになる

| ディレクティブ             | 意味                               |
| -                          | -                                  |
| default-src　              | リソースのアクセス範囲一括設定     |
| sandbox                    | ポップアップ・フォームの許可を設定 |
| upgrade-insecture-requests | HTTPの通信先をHTTPSへ向ける        |

#### Content-Security-Policy-Report-Only
- Content-Security-Policyのチェックは行うが動作は止めない
- 指定したポリシーに反する操作があった場合、指定したURLにレポートを送信する
- `report-uri` -> 報告先のURIを指定する

#### ETag
- リソースのバージョンを一意に特定する文字列
  - リソースが更新されると文字列も更新される
  - 条件付きリクエストで条件を確認するために使用される
- 頭文字のW\は弱いETag値(バイト単位で同じリソースであることを保証しない)を示す

#### Expires
- リソースの有効期限

#### Feature-Policy
- Webサイト全体でどの機能が使用できるかを制御する役割を持っている
- Railsでは`config/initializers/feature_policy.rb`に設定を置く(6.1以降)
  - controllerで機能ごとに設定を上書きすることもできる
- [機能ポリシーの使用](https://developer.mozilla.org/ja/docs/Web/HTTP/Feature_Policy/Using_Feature_Policy)
- [Rails 6.1 adds HTTP Feature Policy](https://blog.saeloun.com/2019/10/01/rails-6-1-adds-http-feature-policy.html)

#### Last-Modified
- リソースが最後に更新された日時

#### Location
- リダイレクトする場合のリダイレクト先

#### Proxy-Authenticate
- プロキシサーバーからクライアントに対する認証要求・認証方式

#### Retry-After
- リクエストを再試行するまでの時間

#### Server
- サーバーで使用しているサーバーのソフトウェアの名前・バージョン・オプション

#### Set-Cookie
- クライアントにCookieを設定する

| 属性     | 意味                                                                               |
| -        | -                                                                                  |
| Domain   | Cookieを送信するドメイン対象を指定する                                             |
| Expire   | Cookieの有効期限(日付)                                                             |
| Path     | Cookieを送信するURLのパス対象を指定する                                            |
| Max-Age  | Cookieの有効期限(秒)                                                               |
| SameSite | 現在のドメインから別のドメインに対してリクエストを送る際、Cookieを送信するかどうか |
| Secure   | https通信時のみ送信する                                                            |
| HttpOnly | JavaScriptから参照できないようにする                                               |

| SameSiteディレクティブ | 意味                                                  |
| -                      | -                                                     |
| none                   | Cookieを送信する                                      |
| strict                 | Cookieを設定したドメインに対してのみCookieを送信する  |
| lax                    | ドメイン間のサブリクエストと外部サイトのURLに送信する |

#### Strict-Transport-Security
- サイトからブラウザに対してHTTPではなくHTTPSを用いて通信を行うよう指示する

#### Trailer
- メッセージボディの送信中に動的に生成される可能性のあるメタデータを提供するため、
  チャンク化されたメッセージの最後に追加のフィールドを含めることを送信者に対して許可する

```
Trailer: header-names
```

#### Transfer-Encoding
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

#### Vary
- 通常のキャッシュキーよりも細かい粒度でキャッシュがバリエーションを持てるようにセカンダリキーを指定する
  - セカンダリキーとして利用するリクエストヘッダのフィールド名を指定する
- サーバーがコンテントネゴシエーションを行えるヘッダを示す
  - コンテントネゴシエーション - クライアントから`Accept-\*`ヘッダで指定された方式でリソースを返す機能
- Varyヘッダの値に基づいて複数の表現をキャッシュできる

| Varyに追加できるヘッダ | 種類                 |
| -                      | -                    |
| Accept                 | メディアタイプ       |
| Accept-Charset         | 文字エンコーディング |
| Accept-Encoding        | 圧縮方式             |
| Accept-Language        | 自然言語             |

```
Vary: Accept-Encoding, Accept-Language
```

#### X-Content-Type-Options
- Content-Typeで指定されたMIMEタイプをブラウザが変更しないことを指定する

#### X-Frame-Options
- ブラウザがページを`<frame>` / `<iframe>` / `<embed>` / `<object>`の中に表示することを許可するかどうかを示す

#### X-XSS-Protection
-  IE/Chrome/SafariにおいてXSS攻撃を検出したときにページの読み込みを停止する

#### WWW-Authenticate
- Webサーバーからクライアントに対する認証要求・認証方式

## 参照
- よくわかるHTTP/2の教科書P32/38-39/41
- Real World HTTP 第2版
- Webを支える技術 山本陽平・著
- パケットキャプチャの教科書
