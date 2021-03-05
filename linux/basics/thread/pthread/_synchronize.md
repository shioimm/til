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
- mutexと共に使用する
  - mutexが共有リソースへのアクセスを排他制御し、条件変数が共有リソースの変化を通知する
  - スレッドはmutexをロックすることで条件変数の状態を検査することができるようになる

#### 条件変数のライフサイクル
1. 通知を待つ
    - `pthread_cond_wait(3)`を使用する
    - `pthread_cond_timedwait(3)`を使用する
    - スレッドは通知待ちスレッドのリストに追加される
    - スレッドはロックしたmutexをアンロックする
2. 通知を送信する
    - `pthread_cond_signal(3)`を使用する
    - `pthread_cond_broadcast(3)`を使用する
3. 通知を受信する
    - スレッドはmutexのロックを試みる

#### 条件変数を用いた同期の取り方
1. スレッドAが合図を待つ
   スレッドAはwait状態になる
2. スレッドBが合図を送る
3. スレッドAが合図を受け取り、ready状態になる
   タスクの切り替えによりスレッドAがrunning状態になり、処理が再開する

#### ミューテックスとの連動による同期の取り方
1. スレッドAがミューテックスを獲得する
2. スレッドAが条件判定を行う(条件を表すグローバルな変数を使用する)
   条件が満たされていない場合、スレッドBが条件を満たすまでwait状態になる
   このときミューテックスが自動的に解放される
3. スレッドBが条件判定の結果(条件を表すグローバルな変数)を書き換える処理を行う
4. 条件判定の結果の書き換えを受け、スレッドAに合図が送られる
5. スレッドAが合図を受け取り、ready状態になる
   スレッドAが自動的に再びミューテックスを獲得する
   スレッドAが再び条件判定を行い、条件が満たされている場合次の処理に移る
6. スレッドAが処理を行い、ミューテックスを解放する

#### 条件変数の操作
- `pthread_cond_init(3)` - 条件変数の初期化
- `pthread_cond_destroy(3)` - 条件変数の削除
- `pthread_cond_wait(3)` - 合図を待つ
- `pthread_cond_timedwait(3)` - 合図を待つ(時間制限付き)
- `pthread_cond_signal(3)` - 合図を送る
- `pthread_cond_broadcast(3)` - 条件変数待ち中の全スレッドへ合図を送る

#### 条件変数属性の操作
- `pthread_condattr_t`構造体 - 条件変数属性
  - `proccess-shared` - プロセス共有
    - 条件変数を単一プロセスのスレッド群のみが使うのか複数プロセスのスレッド群が使うのか制御
  - `clock` - `pthread_cond_timedwait(3)`の時間切れ引数を評価するクロックの種類(クロックID)を制御
- `pthread_condattr_init(3)` - `pthread_condattr_t`構造体の初期化
- `pthread_condattr_destroy(3)` - `pthread_condattr_t`構造体の削除
- `pthread_condattr_getpshared(3)` - `proccess-shared`の取得
- `pthread_condattr_setpshared(3)` - `proccess-shared`の設定
- `pthread_condattr_getclock(3)` - `clock`の取得
- `pthread_condattr_setclock(3)` - `clock`の設定
