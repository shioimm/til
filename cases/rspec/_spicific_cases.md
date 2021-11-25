# 特定の条件で実行する
#### 失敗するスペックだけ実行する
```ruby
# spec_helper.rb
# 指定のパスに実行結果を保存しておく

RSpec.configure do |config|
  config.example_status_persistence_file_path = 'spec/examples.'
end
```

```
$ rspec --only-failures
```

#### 一回でもテストが失敗した時点で終了する

```
$ rspec --fail-fast
```

#### 指定したスペックだけ実行する
```sh
$ rspec --example '実行したいexample / deescribe名(一部)'
```

#### フォーカス中のスペックだけ実行する
```ruby
# spec_helper.rb

RSpec.configure do |config|
  config.filter_run focus: true
end
```

- 実行したいスペックに`f`をつける
- 実行したくないスペックを除外する場合は対象のスペックに`x`をつける
