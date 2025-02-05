# Rails環境を手動でロードする

root以下に作成した新しいディレクトリ内からRails環境にアクセスする場合など

```ruby
require "bundler/setup"
require File.expand_path('../../config/environment', __dir__)

puts Rails.root
```
