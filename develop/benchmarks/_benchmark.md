# library benchmark
- 参照: [library benchmark](https://docs.ruby-lang.org/ja/2.6.0/library/benchmark.html)
- Rubyプログラムのベンチマークを取るライブラリ

```ruby
require 'benchmark'

a = Proc.new { User.ids }
b = Proc.new { User.pluck(:id) }
c = Proc.new { User.map(&:id) }

Benchmark.bmbm do |x|
  x.report(:a) { a.call }
  x.report(:b) { b.call }
  x.report(:c) { c.call }
end

=> [#<Benchmark::Tms:0x00007fd4ff297e40
  @cstime=0.0,
  @cutime=0.0,
  @label="a",
  @real=0.004777000052854419,
  @stime=0.0008360000000000034,
  @total=0.003964000000000023,
  @utime=0.0031280000000000197>,
 #<Benchmark::Tms:0x00007fd4ff29f0f0
  @cstime=0.0,
  @cutime=0.0,
  @label="b",
  @real=0.005436999956145883,
  @stime=0.0011449999999999516,
  @total=0.00404199999999999,
  @utime=0.0028970000000000384>,
 #<Benchmark::Tms:0x00007fd4ff28dbc0
  @cstime=0.0,
  @cutime=0.0,
  @label="c",
  @real=0.0035059999208897352,
  @stime=0.0003849999999999687,
  @total=0.0029609999999999914,
  @utime=0.0025760000000000227>]
```
- cstime -> System CPU time
- cutime -> User CPU time
- label  -> ラベル
- real   -> 実経過時間
- stime  -> System CPU time
- total  -> 合計時間(utime + stime + cutime + cstime)
- utime  -> User CPU time
