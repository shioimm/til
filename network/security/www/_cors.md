# CORS
- Cross Origin Resource Sharing(オリジン間リソース共有)
- オリジン(ドメイン)をまたいでリソースを共有するルール
  - クライアントからサーバーへアクセスする直前までの権限確認プロトコルとして機能する
  - 許可していないクライアント(Webサイト)からのサーバーアクセスを防ぐ目的で使用される
  - リクエスト時の条件やサーバーのレスポンスによって通信の可否が判定される
  - Railsでは[rack-cors](https://github.com/cyu/rack-cors)を使用して、アクセスを許可するドメインの設定を行う

## リソース共有
- XMLHttpRequestやFetch APIによるアクセス

```
オリジン間リクエスト(例):
ドメイン = domain-hoge
オリジン = https://domain-hoge.com

https://domain-hoge.com で提供されているJavaScriptコードが
https://domain-fuga.com/data.json へリクエストを行う
```

## 認証メカニズム
1. リクエストが発行されると、ブラウザは自動的に保護されているOriginヘッダを追加する
  - Originヘッダはリクエスト元のオリジンを広告する
2. サーバーはOriginヘッダを検証し、Accecss-Control-Allow-Originヘッダを付与したレスポンスを返す
3. Accecss-Control-Allow-Originヘッダで指定されたオリジンはリソース共有にオプトインされる

## フロー
- simple cross-origin requestであること
  - simple cross-origin requestの条件を満たさない場合はプリフライトリクエストが必要
- プリフライトリクエストを伴うactual requestであること

### simple cross-origin requestの条件
- リクエストメソッドがGET、POST、HEADのいずれか
- リクエストヘッダにAccept、Accept-Language、Content-Lanuage、Content-Type以外が含まれていない
- Content-Typeの値が`application/x-www-form-urlencodeed`、`multipart/form-data`、`text-plain`のいずれか

### プリフライトリクエストに必要なリクエストヘッダ
- Access-Control-Request-Method - 通信を許可してもらいたいメソッドのリスト
- Access-Control-Request-Headers - 通信を許可してもらいたいリクエストヘッダのリスト
- Origin - 通信元のWebページのドメイン名

### Cookieの取り扱い
- クロスオリジンのデフォルトの通信ではCookieを送信しない
- Cookieを送信する場合はクライアントのJavaScriptに設定し、サーバーの許可が必要
- サーバーはクライアントからの通信を受け、サーバーが許可する内容をレスポンスヘッダで返す
  - Access-Control-Allow-Origin - 通信を許容するオリジン名
  - Access-Control-Allow-Method - 通信を許容するメソッドのリスト
  - Access-Control-Allow-Headers - 通信を許容するリクエストヘッダのリスト
  - Access-Control-Allow-Credentials - サーバーがCookieを受け取るときのみtrueを返す
  - Access-Control-Expose-Headers - レスポンスヘッダのうちクライアントのスクリプトから参照できるヘッダのリスト
  - Access-Control-Max-Age - サーバーがクライアントに対して許容するキャッシュ可能秒数

## 引用
- [オリジン間リソース共有 (CORS)](https://developer.mozilla.org/ja/docs/Web/HTTP/CORS)
- Real World HTTP 第2版
- ハイパフォーマンスブラウザネットワーキング
