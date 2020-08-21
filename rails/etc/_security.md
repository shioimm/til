# セキュリティ
## CSRF
- [CSRF【 Cross Site Request Forgeries 】](http://e-words.jp/w/CSRF.html)
- 認証済みユーザーのリクエストを捏造して悪意のある操作を行う攻撃

### RailsにおけるCSRF対策
- 1. HTMLに一意のセキュリティトークンを出力
  - 同じトークンをセッションCookieにも保存
- 2. JSがX-CSRF-Tokenヘッダにてセキュリティトークンを送信
- 3. サーバーが送信されたトークンとセッションCookieのトークンを照合

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end
```
```haml
= # app/layouts/application.html.haml

= csrf_meta_tags
```

## SQLインジェクション
- [SQLインジェクション【 SQL injection 】](http://e-words.jp/w/SQL%E3%82%A4%E3%83%B3%E3%82%B8%E3%82%A7%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3.html)

### RailsにおけるSQLインジェクション対策
- ユーザーの入力した文字をそのままSQLに埋め込まない
  - paramsハッシュでエスケープする
```ruby
User.where(name: params[:name])
```
- プレースホルダを使用する
```ruby
User.where('name = ?', params[:name])
```
