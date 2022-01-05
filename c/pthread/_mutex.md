# mutex
### mutexの初期化(スタティック)
- スタティックに割り当て、デフォルトの属性を持つmutexに対する初期化

```c
pthread_mutex_t mtx = PTHREAD_MUTEX_INITIALIZER;
```

### `pthread_mutex_init(3)`
- mutexの初期化(ダイナミック)
  - mutexオブジェクトをヒープ上にダイナミックに割り当てる場合
  - mutexオブジェクトがスタック上に割り当てられているオート変数である場合
  - mutexオブジェクトはスタティックに割り当てたがデフォルト以外の属性で初期化する場合

#### 引数
- `*mutex`、`*attr`を指定する
  - `*mutex` - 指定のmutexへのポインタ
  - `*attr` - 予め属性を設定した`pthread_mutexattr_t`構造体へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は正のエラー番号を返す

### `pthread_mutex_lock(3)`
- 指定のmutexをロックする
- mutexがアンロック状態 -> ロック状態へ遷移させる
- mutexがロック状態 -> アンロックされるまで待つ
  - 自スレッドがロックしたmutexへ`pthread_mutex_lock(3)`を呼ぶ -> デッドロック(Linux)
- `pthread_mutex_trylock(3)` - 対象のmutexがロック状態の場合`EBUSY`を返す
- `pthread_mutex_timedlock(3)` - 対象のmutexがロック状態の場合アンロックされるのを待つ時間の上限を設定する

#### 引数
- `*mutex`を指定する
  - `*mutex` - 指定のmutexへのポインタ

#### 返り値
- 数値0を返す
  - エラー時は正のエラー番号を返す

### `pthread_mutex_unlock(3)`
- 指定のmutexをアンロックする
- mutexがロック状態 -> アンロック状態へ遷移させる
- mutexがアンロック状態 -> エラー

#### 引数
- `*mutex`を指定する
  - `*mutex` - 指定のmutexへのポインタ

#### 返り値
- 数値0を返す
  - エラー時は正のエラー番号を返す

### `pthread_mutex_destroy`
- ダイナミックに割り当てたmutexを破棄する
- ダイナミックに割り当てたメモリの中にmutexがある場合、メモリを解放する前に破棄する
- オート変数のmutexは関数がリターンする前に破棄する

#### 引数
- `*mutex`を指定する
  - `*mutex` - 指定のmutexへのポインタ

#### 返り値
- 数値0を返す
  - エラー時は正のエラー番号を返す

## 参照
- 詳解UNIXプログラミング第3版 11. スレッド
- 詳解UNIXプログラミング第3版 12. スレッドの制御
- Linuxプログラミングインターフェース 29章
