# 同期
- 参照: 詳解UNIXプログラミング第3版 11. スレッド
- 参照: 詳解UNIXプログラミング第3版 12. スレッドの制御
- 参照: Linuxプログラミングインターフェース 29章 / 30章

## TL;DR
- mutex - 任意の共有リソースへのアトミックなアクセスを保証する仕組み
- 条件変数 - スレッド間で共有するリソースの変更完了を他のスレッドへ通知する

## mutex
- Pthreadsの排他制御インターフェース

### 状態
- ロック(獲得) / アンロック(解放)
  - mutexをロックしたスレッドがmutexのオーナーとなる
  - mutexをアンロックできるのはmutexのオーナーのみ

### クリティカルセクションの保護
```
1. 共有リソースに対応するmutexにロックをかける
2. 共有リソースへアクセスする
3. 共有リソースに対応するmutexをアンロックする
```
- 複数スレッドがクリティカルセクションへの操作を試みる際、
  mutexをロックできるのは一スレッドのみ
- mutexのアンロック後、次にmutexをロックできるスレッドは
  スケジューリングによって決まる(非決定動作)

### mutexの操作
1. 初期化(アンロック状態)
    - (スタティック)`pthread_mutex_t`に`PTHREAD_MUTEX_INITIALIZER`を代入する
    - (ダイナミック)`pthread_mutex_init(3)`を使用する
2. ロックする
    - `pthread_mutex_lock(3)`を使用する
3. アンロックする
    - `pthread_mutex_unlock(3)`を使用する
4. 破棄
    - 使用するメモリを解放する前に行う

### ミューテックスの操作
- `pthread_mutex_t`型 - ミューテックス変数型
- `pthread_mutex_init(3)` - ミューテックスの初期化
- `pthread_mutex_destroy(3)` - ミューテックスの削除
- `pthread_mutex_lock(3)` - ミューテックスのロック
- `pthread_mutex_trylock(3)` - ミューテックスのロック(ロック時、待機せずに別処理を行う)
- `pthread_mutex_timedlock(3)` - ミューテックスのロック(時間制限付き)
- `pthread_mutex_unlock(3)` - ミューテックスのアンロック

### ミューテックス属性の操作
- `pthread_mutexattr_t`構造体 - ミューテックス属性
  - `proccess-shared` - プロセス共有
    - ミューテックスを単一プロセスのスレッド群のみが使うのか複数プロセスのスレッド群が使うのか制御
  - `robust` - 堅牢性
    - 複数プロセス間で共有しているミューテックスの状態回復問題を扱う
  - `type` - 種別
    - ミューテックスをロックする種別を制御
    - `PTHREAD_MUTEX_NORMAL`
    - `PTHREAD_MUTEX_ERRORCHECK`
    - `PTHREAD_MUTEX_RECURSIVE`
    - `PTHREAD_MUTEX_DEFAULT`
- `pthread_mutexattr_init(3)` - `pthread_mutexattr_t`構造体の初期化
- `pthread_mutexattr_destroy(3)` - `pthread_mutexattr_t`構造体の削除
- `pthread_mutexattr_getpshared(3)` - `proccess-shared`の取得
- `pthread_mutexattr_setpshared(3)` - `proccess-shared`の設定
- `pthread_mutexattr_getrobust(3)` - `robust`の取得
- `pthread_mutexattr_setrobust(3)` - `robust`の設定
- `pthread_mutex_consistent(3)` - 当該ミューテックスをアンロックする前にミューテックスに付随する状態が一貫していることを示す
- `pthread_mutexattr_gettype(3)` - `type`の取得
- `pthread_mutexattr_settype(3)` - `type`の設定

## デッドロック
- 複数ミューテックスがあり、両方をロックする必要がある場合、
  ロックする順序を制御することでデッドロックを回避する
  - 全てのスレッドが同じ順序でミューテックスをロックすればデッドロックはおきない
  - あるスレッドが他のスレッドの逆順にミューテックスをロックするとデッドロックが起こる
  - ミューテックスをロックする順序が制御できない場合、
    取得したロック群を全て解放し、時間をおいて再ロックする
