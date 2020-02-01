# RSpec
## マッチャ
### `satisfy`
- 参照: [satisfy matcher](https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/satisfy-matcher)
- ブロックの中でsubjectの返り値に対して`true / false`を確認することができる
```ruby
subject { number } # number = 10

is_expected.to satisfy { |v| v.modulo(5).zero? }
is_expected.not_to satisfy { |v| v.modulo(3).zero? }
```

## Howto
### 特定のスペックだけ実行する
- 失敗するスペックだけ実行する
```ruby
# spec_helper.rb

RSpec.configure do |config|
  config.example_status_persistence_file_path = 'spec/examples.'
end
```
```sh
$ rspec --only-failures
```

- 一回でもテストケースが失敗した時点で終了する
```sh
$ rspec --fail-fast
```

- 指定したスペックだけ実行する
```sh
$ rspec --example '実行したいexample / edescribe名(一部)'
```

- フォーカス中のスペックだけ実行する
```ruby
# spec_helper.rb

RSpec.configure do |config|
  config.filter_run focus: true
end
# 実行したいスペックに`f`をつける
# 実行したくないスペックを除外する場合は対象のスペックに`x`をつける
```

### 出力の変更
- テストを実行せずにテスト一覧を出力する
```sh
$ rspec --dry-run
```

- 実行に時間がかかったスペックを出力する
```sh
$ rspec --profile
```
