# 特定のcontrollerでBasic認証をスキップする
- `http_basic_authenticate_with`をスキップしたい

## 課題
- `http_basic_authenticate_with`にはスキップするためのオプションが指定されていない

## 前提
```ruby
class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: ENV['BASIC_USER'], password: ENV['BASIC_PASSWORD']
end
```

## 問題解決の経緯
1. [Rails API doc](https://edgeapi.rubyonrails.org/)で`http_basic_authenticate_with`を確認
2. 解説が記載されていないため`http_basic_authenticate_with`のソースコードを確認
    - `http_basic_authenticate_or_request_with`を`before_action`で設定する処理が記述されている
    - [`ActionController::HttpAuthentication::Basic::ControllerMethods.http_basic_authenticate_with`](https://github.com/rails/rails/blob/947a9f903a9801429ab7953e68f72ab54a45d3cf/actionpack/lib/action_controller/metal/http_authentication.rb#L72)
3. アプリケーションコード側で明示的に`http_basic_authenticate_or_request_with`を`before_action`するように変更
4. `3`の変更により、アプリケーションコード側で明示的に`http_basic_authenticate_or_request_with`を`skip_before_action`できるようになった
