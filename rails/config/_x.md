# `Rails.application.config.x`

```ruby
# ユーザー定義値の設定
Rails.configuration.x.foo = 'foo'
Rails.configuration.x.foo # => 'foo'

# 階層化したユーザー定義値の設定
Rails.configuration.x.foo.bar = 'bar'
Rails.configuration.x.foo.bar # => 'bar'
```

## 参照
- [Custom configuration](https://guides.rubyonrails.org/configuring.html#custom-configuration)
