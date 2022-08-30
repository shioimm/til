# HSTS (HTTP Strict Transport Security)
- サーバーからクライアントに対してHTTPSでの通信を強制するポリシーメカニズム (RFC6797)
- 証明書エラーの見過ごし、混在コンテンツ、CookieへのSecure属性の付け忘れなどの問題に対応する

#### HSTS利用時の動作
1. スキームがhttpになっているURLがhttpsへと透過的に書き換えられる
2. すべての証明書エラーが深刻(fatal)とみなされるようになる

## 動作フロー
- Webサイトがブラウザに対してHSTSへの対応を求める場合、暗号化されたHTTPレスポンスのすべてに対して
  Strict-Transport-Securityレスポンスヘッダを立てる

```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload

// includeSubDomains - ヘッダで指定されたホストとその下位のドメインすべてでHSTSが有効になるべき
```

- ブラウザはStrict-Transport-Securityレスポンスヘッダを送信したサイトのURLを保持する
- ブラウザはTLS接続にエラーがなければmax-ageパラメータで指定された保持期間だけHSTSを有効にする
- ブラウザは指定の保持期限まで対象のURLに対してHTTPSスキームを利用してリクエストを行う
  - 平文による接続や証明書エラー (自己署名証明書を含む) がある接続の場合はHSTSヘッダを無視する
- Webサイトはサイトを訪問しHSTSが有効化済みブラウザの再訪問時にHSTSを取り消すことが可能

```
Strict-Transport-Security: max-age=0
```

- Webサイトが複数のホスト名にまたがって運用されている場合、そのすべてでHSTSを有効にする必要がある

## 参照
- [Strict-Transport-Security](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Strict-Transport-Security)
- 安全なWebアプリケーションの作り方(脆弱性が生まれる原理と対策の実践)
- Real World HTTP 第2版
- プロフェッショナルSSL/TLS
