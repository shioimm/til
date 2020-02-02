# セキュリティ
## CSRF
- [クロスサイトリクエストフォージェリ](https://ja.wikipedia.org/wiki/%E3%82%AF%E3%83%AD%E3%82%B9%E3%82%B5%E3%82%A4%E3%83%88%E3%83%AA%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88%E3%83%95%E3%82%A9%E3%83%BC%E3%82%B8%E3%82%A7%E3%83%AA)
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
