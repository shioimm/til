# Stackprof

```ruby
require 'stackprof'

StackProf.run(mode: :wall, out: 'tmp/stackprof-cpu-myapp.dump', raw: true) do
  1_000_000.times { puts 'foo' }
end
```

```
# 測定結果を標準出力
$ stackprof tmp/stackprof-cpu-myapp.dump --text
==================================
  Mode: wall(1000)
  Samples: 2615 (0.00% miss rate)
  GC: 60 (2.29%)
==================================
     TOTAL    (pct)     SAMPLES    (pct)     FRAME
      2350  (89.9%)        2350  (89.9%)     IO#write
      2530  (96.7%)          65   (2.5%)     block (2 levels) in <main>
      2412  (92.2%)          62   (2.4%)     IO#puts
      2465  (94.3%)          53   (2.0%)     Kernel#puts
        42   (1.6%)          42   (1.6%)     (sweeping)
      2555  (97.7%)          25   (1.0%)     Integer#times
        17   (0.7%)          17   (0.7%)     (marking)
        60   (2.3%)           1   (0.0%)     (garbage collection)
      2555  (97.7%)           0   (0.0%)     <main>
      2555  (97.7%)           0   (0.0%)     <main>
      2555  (97.7%)           0   (0.0%)     StackProf.run
      2555  (97.7%)           0   (0.0%)     block in <main>

# 測定結果をフレームグラフで出力
$ stackprof tmp/stackprof-cpu-myapp.dump --flamegraph > flamegraph.js
$ stackprof tmp/stackprof-cpu-myapp.dump --flamegraph-viewer > flamegraph.js
```

### mode
- `:wall` - `ITIMER_REAL`と`SIGALRM`を使用 (デフォルト)
- `:cpu`  - `ITIMER_PROF`と`SIGPROF`を使用
- `:object` - `RUBY_INTERNAL_EVENT_NEWOBJ`を使用
- カスタム (StackProf.sample によるユーザー定義)

#### modeごとに利用されるインターバルタイマー
- `ITIMER_REAL` - 実時間 (real time) で減少し、満了すると`SIGALRM`が送出される
- `ITIMER_PROF` - システムが当該プロセスの処理を行うと減少し、満了すると`SIGPROF`が送出される

## 参照
- [tmm1/stackprof](https://github.com/tmm1/stackprof)
