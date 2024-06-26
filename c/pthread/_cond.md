# 条件変数
### 条件変数の初期化(スタティック)
- スタティックに割り当て、デフォルトの属性を持つ条件変数に対する初期化

```c
pthread_cond_t mtx = PTHREAD_COND_INITIALIZER;
```

### `pthread_cond_init(3)`
- 条件変数の初期化(ダイナミック)
  - 条件変数オブジェクトをヒープ上にダイナミックに割り当てる場合
  - 条件変数オブジェクトがスタック上に割り当てられているオート変数である場合
  - 条件変数オブジェクトはスタティックに割り当てたがデフォルト以外の属性で初期化する場合

#### 引数
- `*cond`、`*attr`を指定する
  - `*cond` - 指定の条件変数へのポインタ
  - `*attr` - 予め属性を設定した`pthread_condattr_t`構造体へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は正のエラー番号を返す

### `pthread_cond_wait(3)`
- 指定の条件変数から通知が届くまで待つ
- `pthread_cond_timedwait(3)` - 待機時間の条件を設定する

#### 引数
- `*cond`、`*mutex`を指定する
  - `*cond` - 指定の条件変数へのポインタ
  - `*mutex` - 対象となるmutexへのポインタ

#### 返り値
- 数値0を返す
  - エラー時は正のエラー番号を返す

### `pthread_cond_signal(3)`
- 指定の条件変数へ通知を送信する
- 複数のスレッドが`pthread_cond_wait(3)`しているとき、
  待機中のスレッドのうちどれかの待機を終了させる

#### 引数
- `*cond`を指定する
  - `*cond` - 指定の条件変数へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は正のエラー番号を返す

### `pthread_cond_broadcast(3)`
- 指定の条件変数へ通知を送信する
- 複数のスレッドが`pthread_cond_wait(3)`しているとき、
  待機中の全スレッドの待機を終了させる

#### 引数
- `*cond`を指定する
  - `*cond` - 指定の条件変数へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は正のエラー番号を返す

### `pthread_cond_destroy`
- ダイナミックに割り当てた条件変数を破棄する
- ダイナミックに割り当てたメモリの中に条件変数がある場合、メモリを解放する前に破棄する
- オート変数の条件変数は関数がリターンする前に破棄する

#### 引数
- `*cond`を指定する
  - `*cond` - 指定の条件変数へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は正のエラー番号を返す

## 参照
- 詳解UNIXプログラミング第3版 11. スレッド
- 詳解UNIXプログラミング第3版 12. スレッドの制御
- Linuxプログラミングインターフェース 29章
