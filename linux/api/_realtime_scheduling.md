# リアルタイムスケジューリング
### `sched_get_priority_min(2)` / `sched_get_priority_max(2)`
- 指定したポリシーの優先度の範囲を取得する

#### 引数
- `poricy`を指定する
  - `poricy` - 対象のスケジューリングポリシー

#### 返り値
- 非負の整数(優先度)を返す
  - エラー時は数値-1を返す

### `sched_getscheduler(2)`
- 指定のプロセスのスケジューリングポリシーと優先度を取得する
- `sched_getparam(2)` - 優先度のみを取得する

#### 引数
- `sched_getscheduler(2)` - `pid`を指定する
  - `pid` - 対象のプロセス(数値0で自プロセス)
- `sched_getparam(2)` - `pid`、`poricy`、`*param`を指定する
  - `pid` - 対象のプロセス(数値0で自プロセス)
  - `*param` - 対象プロセスの優先度を格納するための`sched_param`構造体へのポインタ

#### 返り値
- `sched_getscheduler(2)` - スケジューリングポリシーを返す
  - エラー時は数値-1を返す
- `sched_getparam(2)` - 数値0を返す
  - エラー時は数値-1を返す

### `sched_setscheduler(2)`
- 指定のプロセスのスケジューリングポリシーと優先度を設定する
- `sched_setparam(2)` - 優先度のみを変更する

#### 引数
- `pid`、`poricy`、`*param`を指定する
  - `pid` - 対象のプロセス(数値0で自プロセス)
  - `poricy` - 対象のスケジューリングポリシー
  - `*param` - `sched_param`構造体へのポインタ

```c
struct sched_param {
  int sched_priority;
};
```

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `sched_yield(2)`
- リアルタイムプロセスが自発的にCPUを手放す

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

## 参照
- 例解UNIX/Linuxプログラミング教室P185-224
- 詳解UNIXプログラミング第3版 7. プロセスの環境 / 8. プロセスの制御 / 9. プロセスの関係
- Linuxプログラミングインターフェース 6章
