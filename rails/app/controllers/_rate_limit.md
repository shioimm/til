# レート制限 / レートリミット / rate limiting (Rails 8,0~)

```ruby
class SignupController < ApplicationController
  rate_limit to: 4, within: 1.minute, only: :create

  def create
    # ...
  end
end
```

- デフォルトではIPアドレスベースでリミットをかける (カスタムする場合はbyを指定)

```ruby
rate_limit to: 4, within: 1.minute, by: -> { request.domain }, only: :create
```

- デフォルトでは上限を超えた際に429 Too Many Requestが発生 (カスタムする場合はwithを指定)

```ruby
rate_limit to: 4, within: 1.minute, with: -> { redirect_to(other_url), alert: "Try again later" }, only: :create
```

- リクエスト数を追跡・制限するためキャッシュストアにユーザー、IPアドレスごとのリクエスト数、タイムスタンプを保存する
- デフォルトではRailsが使用しているキャッシュストアを利用する (カスタムする場合はstoreを指定)

```ruby
class SignupController < ApplicationController
  RATE_LIMIT_STORE = ActiveSupport::Cache::RedisCacheStore.new(url: ENV["REDIS_URL"])
  rate_limit to: 8, within: 2.minutes, store: RATE_LIMIT_STORE
end
```

- [Rails 8: 組み込みのレート制限APIを導入（翻訳）](https://techracho.bpsinc.jp/hachi8833/2024_02_20/139497)
