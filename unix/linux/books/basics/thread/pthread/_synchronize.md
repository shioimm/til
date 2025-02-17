# 同期
- 参照: 詳解UNIXプログラミング第3版 11. スレッド
- 参照: 詳解UNIXプログラミング第3版 12. スレッドの制御
- 参照: Linuxプログラミングインターフェース 29章 / 30章

## TL;DR
- mutex - 任意の共有リソースへのアトミックなアクセスを保証する仕組み
- 条件変数 - スレッド間で共有するリソースの変更完了を他のスレッドへ通知する

## mutex
- Pthreadsの排他制御インターフェース
- 複数のスレッドが同時に共有リソースへアクセスするのを制御する

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

### mutexのライフサイクル
1. 初期化(アンロック状態)
    - (スタティック)`pthread_mutex_t`に`PTHREAD_MUTEX_INITIALIZER`を代入する
    - (ダイナミック)`pthread_mutex_init(3)`を使用する
2. ロックする
    - `pthread_mutex_lock(3)`を使用する
    - `pthread_mutex_trylock(3)`を使用する
    - `pthread_mutex_timedlock(3)`を使用する
3. アンロックする
    - `pthread_mutex_unlock(3)`を使用する
4. (ダイナミックに初期化した場合のみ)破棄
    - `pthread_mutex_destroy(3)`を使用する

### mutexの性能
- mutexはアトミックなマシン語futexで実装されており、
  ロックが衝突する場合のみ`futex(2)`システムコールを発行する
- mutexによる性能低下の影響は軽微

### mutex属性の操作
- `pthread_mutexattr_t`構造体 - ミューテックス属性
  - mutexの種類
    - `PTHREAD_MUTEX_NORMAL`
    - `PTHREAD_MUTEX_ERRORCHECK`
    - `PTHREAD_MUTEX_RECURSIVE`
    - `PTHREAD_MUTEX_DEFAULT`
  - mutexのプロセス間共有の制御
  - mutexの堅牢性(複数プロセス間で共有しているmutexの状態回復問題を扱う)

### mutexのデッドロック
- それぞれ独立したmutexに保護される複数の共有リソースへ連続してアクセスする処理において、
  複数のスレッドが不用意にmutex群をロックするとデッドロックが発生しうる

```
スレッドA                  | スレッドB
  ↓                        |   ↓
pthread_mutex_lock(mutex1) | pthread_mutex_lock(mutex2)
  ↓                        |   ↓
pthread_mutex_lock(mutex2) | pthread_mutex_lock(mutex1)
```

- 複数のmutexがあり、すべてをロックする必要がある場合、
  ロックする順序を制御することでデッドロックを回避する
  - 全てのスレッドが同じ順序でmutexをロックすればデッドロックはおきない
  - mutexをロックする順序が制御できない場合
    - ロックしたmutex群を全て解放し、時間をおいて再ロックする
    - `pthread_mutex_trylock(2)`を使用してエラーハンドリングを行う

```
スレッドA                  | スレッドB
  ↓                        |   ↓
pthread_mutex_lock(mutex1) |   ↓
  ↓                        |   ↓
pthread_mutex_lock(mutex2) | pthread_mutex_lock(mutex1)
                           |   ↓
                           | pthread_mutex_lock(mutex2)
```

## 条件変数
- 共有リソースの状態変化を一スレッドから他スレッドへ通知する / 他スレッドは通知を待つ
  - mutexは共有リソースへのアクセスを排他制御し、条件変数は共有リソースの変化を通知する
- mutexとセットで使用する
  - スレッドはmutexをロックすることで条件変数の状態を検査することができるようになる
- 一つの条件変数は一つまたは複数の共有リソースに対応した意味を持つ

### 条件変数による処理の基本動作
- 待機
- 通知

### mutexと条件変数のライフサイクル
1. スレッドが共有リソースの状態検査の前処理としてmutexをロックする
2. スレッドが共有リソースの状態を検査する
3. 共有リソースが目的の状態でなければ、
   スレッドはロックしたmutexをアンロックして通知を待つ
    - `pthread_cond_wait(3)`を使用する
    - `pthread_cond_timedwait(3)`を使用する
    - スレッドは通知待ちスレッドのリストに追加される
    - 他のスレッドがmutexをロックできるようになる
4. 他のスレッドが通知を送信する
    - `pthread_cond_signal(3)`を使用する
    - `pthread_cond_broadcast(3)`を使用する
5. スレッドが通知を受信し、mutexの再ロックを試みる
    - mutexをロックできた場合は共有リソースにアクセスする
    - mutexをロックできなかった場合はロックできるまでブロックする

### 条件変数属性の操作
- `pthread_condattr_t`構造体 - 条件変数属性
  - mutexのプロセス間共有の制御
  - `pthread_cond_timedwait(3)`のタイムアウトを評価するクロックの種類の制御

## バリア
- 並列動作している複数のスレッドを協調するために使える同期機構
  - 協調動作している全てのスレッドが同一地点に達するまで各スレッドが待つ
  - 任意個のスレッドが全て処理を完了するまで待ち合わせる
    全てのスレッドがバリアに達すると処理を続行できる

### バリアの操作
- `pthread_barrier_init(3)` - バリアの初期化
- `pthread_barrier_destroy(3)` - バリアの破棄
- `pthread_barrier_wait(3)` - 当該スレッドが他のスレッドを待ち合わせ開始

## rwlock(共有排他ロック)
- mutexより高い並列度を持つ同期機構
- ロック種類を読み取り・書き込みの二種類に分類する
  - 読み取りロック - 複数スレッドが同時に獲得することができる
    - 書き込みロックを獲得しているスレッドがある場合、
      当該スレッドが書き込みロックをアンロックするまで処理をブロックする
  - 書き込みロック - ひとつのスレッドのみが獲得することができる
    - 読み取りロックを獲得しているスレッドがある場合、
      当該スレッドが書き込みロックをアンロックするまで処理をブロックする

### rwlockの操作
- `pthread_rwlock_init(3)` - rwlockの初期化
- `pthread_rwlock_destroy(3)` - rwlockの削除
- `pthread_rwlock_rdlock(3)` - 読み取りロック
- `pthread_rwlock_tryrdlock(3)` - 読み取りロック(条件付き)
- `pthread_rwlock_rdlock(3)` - 読み取りロック(時間制限付き)
- `pthread_rwlock_wrlock(3)` - 書き込みロック
- `pthread_rwlock_trywrlock(3)` - 書き込みロック(条件付き)
- `pthread_rwlock_timedwrlock(3)` - 書き込みロック(時間制限付き)
- `pthread_rwlock_unlock(3)` - rwlockのアンロック

## スピンロック
- ビジーウェイトする同期機構
  - ビジーウェイト - 内部で`futex(2)`を実行せず、CPUを手放さない
    - ロックを獲得できるまでループによりCPUを消費する

## スピンロックの操作
- `pthread_spin_init(3)` - スピンロックの初期化
- `pthread_spin_destroy(3)` - スピンロックの破棄
- `pthread_spin_lock(3)` - スピンロックのロック
- `pthread_spin_trylock(3)` - スピンロックのロック(条件付き/スピンしない)
- `pthread_spin_unlock(3)` - スピンロックのアンロック
