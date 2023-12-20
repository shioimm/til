# Stackprof

```ruby
require 'stackprof'

StackProf.run(mode: :cpu, out: 'path/to/<ファイル名>.dump', raw: true) do
  # 計測したい処理
end
```

```
# 測定結果を標準出力
$ stackprof path/to/<ファイル名>.dump

# 測定結果をフレームグラフで出力
stackprof --d3-flamegraph path/to/<ファイル名>.dump > path/to/<ファイル名>.html
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
