# ハッシュのキーを変換する
```ruby
# 文字列 -> シンボル
{ 'foo' => 'bar' }.deep_symbolize_keys

# 文字列 <- シンボル
{ :foo => 'bar' }.stringify_keys
```
