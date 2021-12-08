# benchmark-ips
- [evanphx/benchmark-ips](https://github.com/evanphx/benchmark-ips)
- 対象の処理の1秒あたりのイテレーション回数を計測する

```ruby
require 'benchmark/ips'

Benchmark.ips do |x|
  # 設定 (オプション)
  x.config(:time => 5, :warmup => 2)

  x.report("MESSAGE1") { 実行する処理 }
  x.report("MESSAGE2") { |times| 実行する処理 }

  # 比較結果を出力
  x.compare!
end
```
