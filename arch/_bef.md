# BEF
- Backends For Frontends (フロントエンドのためのバックエンドサーバー)
- フロントエンドのためにバックエンドAPIをコールしたり、HTMLを生成したりする
- 「クライアント - リバースプロキシ - BEF - APIサーバー」という構成を取ることが多い

#### BEFが解決する課題
- クライアントの多様化に伴いクライアントからの要求も多様化する
- クライアントごとの要求を吸収し、バックエンドのAPIサーバとの橋渡しを行う役としてBEFが必要とされる

## 認証
- BEF / ブラウザ間でランダムな認証トークンを利用してBEFがJWTトークンを発行し、
  後段のサービスにJWTを送付する手法がある
- 認証情報を含むJWTをJavaScriptから操作できる場所 (CookieやlocalStorage) に直接格納すると
  クロスサイトリクエストフォージェリの危険性を増すため

## 参照
- [BFF（Backends For Frontends）超入門――Netflix、Twitter、リクルートテクノロジーズが採用する理由](https://atmarkit.itmedia.co.jp/ait/articles/1803/12/news012.html)
