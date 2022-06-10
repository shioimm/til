# `spec_helper.rb`
#### 失敗するスペックだけ実行する

```ruby
RSpec.configure do |config|
  # 最後に実行したexampleの状態を記録するファイル名を指定
  config.example_status_persistence_file_path = 'spec/examples/<FileName>.txt'
end
```

```
$ rspec --only-failures
```

#### フォーカス中のスペックのみ実行する
```ruby
RSpec.configure do |config|
  config.filter_run focus: true
end
```

- 実行したいスペックに`f`をつける
- 実行したくないスペックを除外する場合は対象のスペックに`x`をつける
