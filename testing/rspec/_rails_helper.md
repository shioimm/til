# `rails_helper.rb`

```ruby
RSpec.configure do |config|
  # テスト終了時にDBトランザクションをロールバックする (default: true)
  # 特定のspecの実行時のみトランザクションを無効化したい場合などは
  # 設定をfalseにした上でDatabaseCleaner系のライブラリを導入し、タグでon/offを切り替える
  config.use_transactional_fixtures = true
end
```
