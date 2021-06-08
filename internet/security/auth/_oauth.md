# OAuth
- 認証ではなく認可のための仕組み

## 概念
- 認可サーバー - ユーザー情報を持つサーバー
- リソースサーバー - ユーザーが認可した権限で自由にアクセスできる対象
- クライアント - ユーザーが新たに使用したいサービス

## フロー
#### Authorization Code
- 通常のフロー

#### Clients Credentials Grant
- ユーザーの同意なしに`client_id`と`client_secret`を使用してアクセスできるようにするフロー

#### Device Code Grant
- パスワード入力用のキーボードがないような組み込み危機向けのフロー

#### Resource Owener Password Credentials Grant
- 認可サーバーに信頼されているクライアントが使用するフロー
- クライアント自身がユーザーのID/PWに触れる

#### Implicit Code
- `client_secret`無しでアクセスするフロー

## 参照
- Real World HTTP 第2版
