# Authorization

```
Authorization: <認証方式> <認証情報>
```

- 一般的にはクライアントのリクエストに対してサーバがUnauthorizedステータスとWWW-Authenticateヘッダを返し、
  クライアントはAuthorizationヘッダを付与して再びリクエストする

#### Authorization: Bearer ...
- RFC 6750
- あらかじめトークンを発行しておき、そのトークンを持参した者 (Bearer) にアクセス権限を与える

```ruby
class PostsController < ApplicationController
  TOKEN = "secret"
  before_action :authenticate

  # ...

  private

  def authenticate
    authenticate_or_request_with_http_token do |token, _options|
      ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
    end
  end
end
```

## 参照
- https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Authorization
- https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Token.html
