# シグナル
## シグナルの送信
### `kill(2)`
- プロセスから他のプロセスへシグナルを送信する
  - 特権プロセスはどのプロセスに対してもシグナルを送信することができる
  - 非特権プロセスは自身の実ユーザーIDまたは実効ユーザーIDが
    送信先プロセスの実ユーザーIDまたはset-user-IDに一致する場合
    シグナルを送信することができる
- 自プロセスはシグナルを`kill(3)`から戻る前に受信する
- `killpg(2)` - 指定したプロセスグループ内の全プロセスへシグナルを送信する

#### 引数
- `pid`、`sig`を返す
  - `pid` - シグナル送信先プロセスを示すPID
    - `pid > 0` - 指定したPIDを持つ子プロセス
    - `pid == 0` - 親プロセスと同じプロセスグループに属する子プロセス
    - `pid == -1` - 任意の子プロセス(`wait`と同じ)
    - `pid < -1` - プロセスグループIDが指定したPIDの絶対値に等しい子プロセス
  - `sig` - 送信するシグナルを示すマクロ
    - `sig`に0を指定すると、`pid`のプロセスが存在するかどうかを調べることができる
      `EPERM`またはエラーが返ってこなければ存在する

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `raise(3)`
- 自プロセスへシグナルを送信する
- `kill(getpid(), sig)`と等価
  - スレッド対応システムの場合は`pthread_kill(pthread_self(), sig)`と等価
- 自プロセスはシグナルを`raise(3)`から戻る前に受信する

#### 引数
- `sig`を返す
  - `sig` - 送信するシグナルを示すマクロ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `abort(3)`
- 自プロセスへシグナル`SIGABRT`を送信する
  - `SIGABRT`のデフォルト動作はコアダンプ後プロセス終了

## シグナルセット
### `sigemptyset(2)` / `sigfillset(2)`
- シグナルセットの初期化
  - `sigemptyset(2)` - 指定のシグナルセットから全てのシグナルを削除
  - `sigfillset(2)` - 指定のシグナルセットに全てのシグナルを追加

#### 引数
- `*set`を指定する
  - `*set` - シグナルセットへのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値0以外を返す

### `sigaddset(2)` / `sigdelset(2)`
- シグナルセットへのシグナルの追加 / 削除

#### 引数
- `*set`、`sig`を指定する
  - `*set` - シグナルセットへのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `sigismember(2)`
- シグナルセットへシグナルがセットされているかの確認

#### 引数
- `*set`、`sig`を指定する
  - `*set` - シグナルセットへのポインタ

#### 返り値
- 真の場合、数値0を返す
  - 偽の場合、数値-1を返す

## シグナル動作の変更
### `signal(2)`
- 指定のシグナルの動作を変更する
- `sigaction(2)`よりも設定できる機能が少なく、可搬性も低い

#### 引数
- `sig`、`*handler`を指定する
  - `sig` - 動作を変更するシグナルを示すマクロ
  - `*handler` - シグナル受信時に実行する関数へのポインタ

```c
// ハンドラとして設定する関数の形式

void handler(int sig)
{
  // 処理内容
}
```

```c
// handlerをtypedefしておくと便利

#define _GNU_SOURCE

typedef void(*sighandler_t)(int);

sighandler_t signal(int sig, sighandler_t handler);
```

#### 返り値
- 変更前のシグナル動作へのポインタを返す
  - エラー時は`SIG_ERR`を返す

### `sigaction(2)`
- 指定のシグナルの動作を変更する
- `signal(2)`より柔軟性・可搬性に優れる

#### 引数
- `sig`、`*act`、`*oldact`を指定する
  - `sig` - 動作を変更するシグナルを示すマクロ
  - `*act` - 変更前の動作を表す`sigaction`構造体へのポインタ
  - `*oldact` - 変更前の動作を表す`sigaction`構造体へのポインタ

```c
struct sigaction {
  // シグナルハンドラへのポインタ
  union {
    void     (*sa_handler)(int);
    void     (*sa_sigaction)(int, siginfo_t *, void *); // シグナル捕捉時にシグナル番号以外の詳細な情報も取得できる
  } __sigaction_handler;

  sigset_t   sa_mask;            // ハンドラ実行中にブロックするシグナル
  int        sa_flags;           // ハンドラを操作するフラグ
  void     (*sa_restorer)(void); // システムが使用する
};

#define sa_hander __sigaction_handler.sa_hander
#define sa_sigaction __sigaction_handler.sa_sigaction
```

```c
// Ex.

void handler(int sig, siginfo_t *siginfo, void *ucontext);

struct sigaction act;

sigemptyset(&act.sa_mask);
act.sa_sigaction = handler;
act.sa_flags  = SA_SIGINFO;

if (sigaction(SIGINT, &act, NULL) == -1) {
  // ...
}
```

```
// siginfo_t構造体

siginfo_t {
  int      si_signo;   // シグナルハンドラを呼び出したシグナル番号
  int      si_code;    // シグナル発生源に関する付加情報
  int      si_trapno;  // ハードウェアが生成したシグナル用のトラップ番号
  sigval_t si_value;   // sigqueue()に指定した不可情報
  pid_t    si_pid;     // シグナルを送信したPID
  uid_t    si_uid;     // シグナルを送信した実ユーザーID
  int      si_errno;   // エラー番号
  void    *si_addr;    // シグナルが発生したアドレス(ハードウェアが生成したシグナルのみ)

  // 非標準のLinux拡張
  int      si_timerid; // カーネル内のタイマーID
  int      si_overrun; // タイマーのオーバーラン回数
  long     si_band;    // IOイベントの帯域イベント
  int      si_fd;      // IOイベントのファイルディスクリプタ

  // SIGCHLDの場合
  int      si_status;  // 子プロセスの終了コード or シグナル番号
  clock_t  si_utime;   // 子プロセスが消費したユーザーCPU時間
  clock_t  si_stime;   // 子プロセスが消費したシステムCPU時間
}
```

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

## シグナルの待機
### `pause(2)`
- シグナルハンドラが実行されるまで自プロセスの実行を停止する

#### 返り値
- 数値-1を返す

## シグナルの説明文字列
### `strsignal(3)`
- 配列`sys_siglist`からシグナルの説明文字列を参照する

#### 引数
- `sig`を指定する

#### 返り値
- シグナルを説明する文字列へのポインタを返す

## シグナルマスク
### `sigprocmask(2)`
- シグナルマスクを変更する

#### 引数
- `how`、`*set`、`*oldset`を指定する
  - `how` - シグナルマスクをどのように変更するかを指定するフラグ
  - `*set` - 新しいシグナルマスクへのポインタ
  - `*oldset` - 変更前のシグナルマスクへのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `sigpending(2)`
- 保留中のシグナルセットを参照する

#### 引数
- `*set`を指定する
  - `*set` - 取得したシグナルセットを格納するシグナルセットへのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

## シグナルハンドラ内からのグローバルジャンプ
### `sigsetjmp(3)`
- シグナルマスクを保存する`setjmp`

#### 引数
- `env`、`savesigs`を指定する
  - `env` - 環境を保存する`sigjmp_env`型のバッファ
  - `savesigs` - 数値0以外を指定することでシグナルマスクを`env`へ退避、ジャンプ後に復元する
    - 数値0を指定するとシグナルマスクを退避・復元しない

#### 返り値
- 数値0を返す

### `siglongjmp(3)`
- シグナルマスクを復元する`longjmp`

#### 引数
- `env`、`val`を指定する
  - `env` - 環境を保存する`jmp_env`型のバッファ
    (プログラムカウンタレジスタとスタックポインタレジスタ)

#### 返り値
- 数値0以外を返す

## シグナル処理専用スタック
### `sigaltstack(2)`
- シグナル処理専用スタックを設定し、
  それまで設定されていたシグナル処理専用スタックの情報(あれば)を返す

#### 引数
- `*sigstack`、`*oldsigstack`を指定する
  - `*sigstack` - シグナル処理専用スタックのアドレスと属性を持つ`stack_t`構造体へのポインタ
  - `*oldsigstack` - それまで設定されていた`stakck_t`構造体へのポインタ

```c
typedef struct {
  void  *ss_sp;    // シグナル処理専用スタックのアドレス
  int    ss_flags; // フラグ SS_ONSTACK / SS_DISABLE
  size_t ss_size;  // シグナル処理専用スタックのサイズ
} stack_t;
```

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

## システムコールへの割り込み・再開
### `siginterrupt(3)`
- シグナル単位で`SA_RESTART`フラグの設定を変更する
- SUSv4では代わりに`sigaction(2)`を使用することを推奨

#### 引数
- `sig`、`flag`を指定する
  - `flag` - シグナル単位で`SA_RESTART`の設定を変更するフラグ
    - 数値1 -> `sig`のシグナルハンドラはブロッキングなシステムコールへ割り込む
    - 数値0 -> ブロッキングなシステムコールは`sig`のシグナルハンドラ後に実行を再開する

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

## リアルタイムシグナル
### `sigqueue(3)`
- 指定のプロセスへリアルタイムシグナルを送信する

#### 引数
- `pid`、`sig`、`value`を指定する
  - `pid` - 送信先のプロセスID
  - `sig` - リアルタイムシグナル
  - `value` - `sigval`型の付加データ

```c
// sigval

union sigval {
  int   sival_int; // 整数を付加
  void *sival_ptr; // ポインタを付加
};
```

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

## シグナルの待ち合わせ
### `sigsuspend(2)`
- 呼び出し元プロセスのシグナルマスクを一時的に任意のマスクに置き換え、
  シグナルを捕捉しハンドラからリターンするまで、プロセスの実行を一時停止する
- シグナルが捕捉されるとシグナルハンドラを実行し、シグナルマスクは元に値に戻る

#### 引数
- `*mask`を指定する
  - `*mask` - `変更後のシグナルマスク`

#### 返り値
- `errno`へ`EINTR`を代入し、数値-1を返す

### `sigwaitinfo(2)
- 指定のシグナルセットのうちいずれかのシグナルが保留されるまで、プロセスの実行を一時停止する
  - 指定のシグナルセットのうちすでに保留されているシグナルがあれば即時リターンする
  - ブロックし保留されたシグナルも受信できる
    - 予めシグナルをブロックしておいてから`sigwaitinfo(2)`を呼ぶのが一般的
- `sigtimedwait(2)` - 時間制限付きの`sigwaitinfo(2)`

#### 引数
- `*set`、`*info`を指定する
  - `*set` - 指定のシグナルセットへのポインタ
  - `*info` - シグナルの情報を格納する`siginfo_t`構造体へのポインタ

#### 返り値
- シグナル番号を返す
  - エラー時は数値-1を返す

### `sigwait(2)`
- 指定したシグナルセット内のいずれかのシグナルが送信されるのを待ち、受信したシグナルを返す

#### 引数
- `*set`、`*sig`を指定する
  - `*set` - 指定のシグナルセットへのポインタ
  - `*sig` - 受信したシグナルを返す数値へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は正のエラー番号を返す

### `signalfd(2)
- シグナルを読み取る特殊なファイルディスクリプタを作成する
- ファイルディスクリプタ作成後は`read(2)`によりシグナルを読み取ることができる
  - `signalfd_siginfo`構造体を格納する程度以上のバッファを用意しておく

```c
// signalfd_siginfo構造体

struct signalfd_siginfo {
  uint32_t ssi_signo;   // シグナル番号
  int32_t  ssi_errno;   // エラー番号(未使用)
  int32_t  ssi_code;    // シグナルコード
  uint32_t ssi_pid;     // 送信元PID
  uint32_t ssi_uid;     // 送信元実ユーザーID
  int32_t  ssi_fd;      // ファイルディスクリプタ
  uint32_t ssi_tid;     // カーネルタイマーID (POSIX タイマー)
  uint32_t ssi_band;    // 帯域イベント(SIGIO)
  uint32_t ssi_overrun; // タイマーのオーバーラン回数
  uint32_t ssi_trapno;  // シグナルの原因となったトラップ番号
  int32_t  ssi_status;  // 終了ステータス or シグナル(SIGCHLD)
  int32_t  ssi_int;     // sigqueue(3)に指定された付加データ(整数)
  uint64_t ssi_ptr;     // sigqueue(3)に指定された付加データ(ポインタ)
  uint64_t ssi_utime;   // 消費したユーザーCPU 時間(SIGCHLD)
  uint64_t ssi_stime;   // 消費したシステムCPU 時間(SIGCHLD)
  uint64_t ssi_addr;    // シグナルが発生したアドレス(ハードウェア関連シグナル)
};
```

#### 引数
- `fd`、`*mask`、`flags`を指定する
  - `fd` - ファイルディスクリプタ
    - 数値-1を指定すると新たなファイルディスクリプタを作成する
    - 数値-1以外を指定するとそのfdに対応する`*mask`を変更する
  - `*mask` - ファイルディスクリプタから読み取るシグナルセットへのポインタ
  - `flags` - 付加的な動作へのフラグ

#### 返り値
- ファイルディスクリプタ番号を返す
  - エラー時は数値-1を返す

## 参照
- Linuxプログラミングインターフェース 20章 / 21章 / 22章
