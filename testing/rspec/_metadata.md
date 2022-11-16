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

- `around`
- `before`
- `after`
