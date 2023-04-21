# メタデータの付与

```ruby
# spec/rails_helper.rb

RSpec.configure do |config|
  config.around(:each, :<MetadataName>) do |example|
    # 処理内容
    example.run # スペックの実行
  end
end
```

#### 実行タイミング
- `around` - 前後
- `before` - 直前
- `after`  - 直後

```
1. around
2. before
3. 処理
4. after
5. around
```

#### 実行単位
- `suite` - RSpec実行中に一回のみ
- `all` - `context` / `describe`単位
- `each` - `it`単位
