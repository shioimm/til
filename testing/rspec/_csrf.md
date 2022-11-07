# テスト内でのPOSTリクエスト時にCSRF保護を有効にする
- デフォルトでは`ActionController::Base.allow_forgery_protection`がfalseに設定されている
- trueに設定し直すことでPOST時にCSRFトークンを送信するようになる

```ruby
RSpec.feature '...', type: :system do
  around do |ex|
    ActionController::Base.allow_forgery_protection = true
    ex.call
  ensure
    ActionController::Base.allow_forgery_protection = false
  end

  scenario '...' do
    # ...
  end
end
```
