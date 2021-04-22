# Basic認証
- 参照: [Basic認証](https://ja.wikipedia.org/wiki/Basic%E8%AA%8D%E8%A8%BC)
- 参照: [「HTTP」の仕組みをおさらいしよう](https://www.atmarkit.co.jp/ait/articles/1608/10/news021.html)
- 参照: Real World HTTP 第2版

## TL;DR
- 最もシンプルで基本的なHTTP認証
  - HTTP認証 - HTTPの通信で行う認証
- 現在はあまり使われておらず、フォームを使ったログイン + Cookieを使ったセッション管理の組み合わせによる認証が一般的

```
# username:passwordをbase64でエンコードした情報
# デコードが容易であるため盗聴や改竄に弱い

base64(username + ":" + password)
```

## ヘッダ
### レスポンスヘッダ
```
WWW-Authenticate: Basic realm=<realm>
```

### リクエストヘッダ
```
Authorization: Basic <credentials>
```

## 認証の流れ
1. [クライアント]リクエストを送信
2. [サーバー]ステータスコード401とWWW-Authenticateヘッダを返す
    - WWW-Authenticateヘッダには認証の種類(Basic)と保護領域が格納される
3. [クライアント]Authorizationヘッダに`Basic`の文字 + 空白 + エンコード済みの認証情報を指定してリクエストを送信
4. [サーバー]ステータスコード200とリクエストされたページを返す
