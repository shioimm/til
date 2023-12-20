# library benchmark

```ruby
require 'benchmark'

Benchmark.bmbm do |x|
  x.report(:a) { <計測したい処理> }
  x.report(:b) { <計測したい処理> }
end
```

- cstime -> System CPU time
- cutime -> User CPU time
- label  -> ラベル
- real   -> 実経過時間
- stime  -> System CPU time
- total  -> 合計時間(utime + stime + cutime + cstime)
- utime  -> User CPU time

## benchmark-ips
- 対象の処理の1秒あたりのイテレーション回数を計測する

```ruby
require 'benchmark/ips'

Benchmark.ips do |x|
  # 設定 (オプション)
  x.config(:time => 5, :warmup => 2)

  x.report(:a) { <計測したい処理> }
  x.report(:b) { <計測したい処理> }

  # 比較結果を出力
  x.compare!
end
```

## 参照
- [library benchmark](https://docs.ruby-lang.org/ja/3.0.0/library/benchmark.html)
- [evanphx/benchmark-ips](https://github.com/evanphx/benchmark-ips)
