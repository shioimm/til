# タイマー / スリープ
- 参照: Linuxプログラミングインターフェース 23章

## TL;DR
- タイマー - 一定時間が経過したことを自プロセスへ通知する機能
- スリープ - プロセス・スレッドの実行を一定時間停止する機能

## タイマー・スリープ時間精度
- タイマー・スリープ時間精度はソフトウェアクロックによって丸め上げられる

## POSIXクロック
- `timespec`構造体を使用し、ナノ秒の解像度でクロックを使用するAPI
- リアルタイムライブラリ`librt`を使用する
  コンパイル時に`-lrt`を指定する必要がある

### POSIXインターバルタイマー
- UNIXタイマーの制約を克服するために用意されたタイマーAPI

#### UNIXタイマーの制約
- 選択できるタイマー種類(3種類)のうち一つしかセットできない
- タイムアウト通知方法がシグナルしかない
- 対応しているシグナルをブロックしている場合、複数回のタイムアウトが発生しても
  シグナルハンドラが一回しか実行されない
- インターバルタイマーの精度が低い(マイクロ秒止まり)

## ファイルディスクリプタ経由のタイマー通知(非標準)
- `timerfd` APIで作成した特殊なファイルディスクリプタを介してタイムアウト通知を読み取ることができる
- ファイルディスクリプタ作成後は`read(2)`によりタイムアウト通知を読み取ることができる
  - タイムアウトが発生していなければ発生するまで`read(2)`はブロックされる

## API
### `alarm(2)`
- 一回だけタイムアウトするタイマーを設定する
- タイムアウト時`SIGALRM`を送信する
- それまでセットされていたタイマーを上書きする
  - 0秒を指定するとタイマーを停止する

#### 引数
- `seconds`を指定する
  - `seconds` - タイムアウトするまでの秒数

#### 返り値
- 以前にセットされたタイマーの残り時間を返す
  初めての場合は数値0を返す

### `setitimer(2)`
- 指定時間後にタイムアウトするインターバルタイマー(定期タイマー)を設定する
- シグナルの送信によってタイムアウトを通知する

#### 引数
- `which`、`*new_value`、`*old_value`を指定する
  - `which` - タイマー種類
    - `ITIMER_REAL` - 実時間をカウント -> `SIGALRM`を送信
    - `ITIMER_VIRTUAL` - プロセスのユーザーCPU時間をカウント -> `SIGVALRM`を送信
    - `ITIMER_PROF` - プロセスのユーザーCPU時間 + システムCPU時間をカウント -> `SIGPROF`を送信
  - `*new_value` - 変更後のタイマーの値を示す`itimerval`構造体へのポインタ
    - `it_interval`に0以外を指定するとタイムアウト時にタイマーがリセットされる
    - `it_value`で残り時間を示す
  - `*old_value` - 変更前のタイマーの値を示す`itimerval`構造体へのポインタ
    - 変更前のタイマーを復元しない場合はNULLを指定する

```c
// itimerval構造体

struct itimerval {
  struct timeval it_interval; // インターバルタイマーの間隔
  struct timeval it_value;    // 次のタイムアウトまでの時間
};
```

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `gettitimer(2)`
- タイマーの現在値(タイムアウトまでの時間)を取得

#### 引数
- `which`、`*curr_value`を指定する
  - `which` - タイマー種類
  - `*curr_value` - タイマーの現在値を格納する`itimerval`構造体へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `sleep(3)`
- 指定された秒数(またはシグナルを捕捉するまで)プロセスの実行を停止する

#### 引数
- `second`を指定する

#### 返り値
- 数値0を返す
  - 中断時は残り秒数を返す

### `nanosleep(3)`
- 指定されたナノ秒数プロセスの実行を停止する

#### 引数
- `*request`、`*remain`を指定する
  - `*request` - 指定のスリープ時間を示す`timespec`構造体へのポインタ
  - `*remain` - 残り時間を格納する`timespec`構造体へのポインタ

#### 返り値
- 数値0を返す
  - エラー時または中断時は数値-1を返す

### `clock_gettime(2)`
- 指定のクロック種類でクロックの現在値を得るPOSIXクロックAPI

#### 引数
- `clockid`、`*tp`を指定する
  - `clockid` - 指定のクロック種類を表すフラグ
  - `*tp` - クロック値を格納する`timespec`構造体へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `clock_settime(2)`
- 指定のクロック種類でクロックの現在値を変更するPOSIXクロックAPI

#### 引数
- `clockid`、`*tp`を指定する
  - `clockid` - 指定のクロック種類を表すフラグ
  - `*tp` - 変更後のクロック値を示す`timespec`構造体へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `clock_getcpuclockid(2)` / `pthread_getcpuclockid(2)`
- 指定のプロセス / スレッドが消費したCPU時間を表すクロックIDを取得するPOSIXクロックAPI

#### 引数
- `clock_getcpuclockid(2)` - `pid`、`*clockid`を指定する
- `pthread_getcpuclockid(2)` - `thread`、`*clockid`を指定する

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `clock_nanosleep(2)`
- 指定されたナノ秒数(またはシグナルを捕捉するまで)プロセスの実行を停止するPOSIXクロックAPI

#### 引数
- `clockid`、`flags`、`*request`、`*remain`を指定する
  - `clockid` - 指定のクロック種類を表すフラグ
  - `flags` - `clock_nanosleep(2)`の動作を制御するフラグ
  - `*request` - 指定のスリープ時間を示す`timespec`構造体へのポインタ
  - `*remain` - 残り時間を格納する`timespec`構造体へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `timer_create(2)`
- 指定のクロック種類でタイマーを新規作成するPOSIXインターバルタイマーAPI

#### 引数
- `clockid`、`*evp`、`*timerid`を指定する
  - `clockid` - 指定のクロック種類を表すフラグ
  - `*evp` - タイムアウトの通知方法を代入した`sigevent`構造体へのポインタ
  - `*timerid` - タイマーIDを代入する領域へのポインタ

```c
union sigval {
  int     sival_int; // 付加データ(整数)
  void   *sival_ptr; // 付加データ(ポインタ)
};

// sigevent構造体

struct sigevent {
  int          sigev_notify; // 通知方法
  int          sigev_signo;  // タイムアウトシグナル
  union sigval sigev_value;  // 付加データまたはスレッド関数の引数
  union {
    pid_t _tid;             // シグナル送信先スレッドID
    struct {
      void (*_function)(union sigval); // スレッド関数
      void *_attribute;
    } _sigev_thread;
  } _sigev_un;
};
```

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `timer_settime(2)`
- 新規作成したタイマーを開始・停止するPOSIXインターバルタイマーAPI

#### 引数
- `timerid`、`flags`、`*value`、`*old_value`を指定する
  - `timerid` - 作成したタイマーid
  - `flags` - `timer_settime(2)`の動作を制御するフラグ
  - `*value` - 変更後のタイマーの値を示す`itimerspec`構造体へのポインタ
  - `*old_value` - 変更前のタイマーの値を示す`itimerspec`構造体へのポインタ
    - 変更前のタイマーを復元しない場合はnullを指定する

```c
// itimerspec構造体

struct itimerspec {
  struct timespec it_interval; // インターバルタイマーの間隔
  struct timespec it_value;    // 最初のタイムアウト
};
```

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `timer_gettime(2)`
- 開始したタイマーの残り時間を取得するPOSIXインターバルタイマーAPI

#### 引数
- `timerid`、`*curr_value`を指定する
  - `timerid` - 作成したタイマーid
  - `*curr_value` - タイマーの残り時間値を示す`itimerspec`構造体へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `timer_delete(2)`
- 新規作成したタイマーを削除するPOSIXインターバルタイマーAPI

#### 引数
- `timerid`を指定する
  - `timerid` - 作成したタイマーid

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `timer_getoverrun(2)`
- 新規作成したタイマーに対して、タイムアウト通知をシグナルで受信する場合、
  タイムアウトが複数回発生した際にオーバーラン回数を取得するPOSIXインターバルタイマーAPI

#### 引数
- `timerid`を指定する
  - `timerid` - 作成したタイマーid

#### 返り値
- タイマーオーバーラン回数を返す
  - エラー時は数値-1を返す

### `timerfd_create(2)`
- 指定のクロック種類でタイムアウト通知を読み取る特殊なファイルディスクリプタを作成する

#### 引数
- `clockid`、`flags`を指定する
  - `clockid` - 指定のクロック種類を表すフラグ
  - `flags` - `timer_create(2)`の動作を制御するフラグ

#### 返り値
- ファイルディスクリプタ番号を返す
  - エラー時は数値-1を返す

### `timerfd_setitime(2)`
- `timerfd_create(2)`で作成したファイルでイスクリプタに対応するタイマーを開始・停止する

#### 引数
- `fd`、`*new_value`、`*old_value`を指定する
  - `*new_value` - 変更後のタイマーの値を示す`itimerspec`構造体へのポインタ
  - `*old_value` - 変更前のタイマーの値を示す`itimerspec`構造体へのポインタ
    - 変更前のタイマーを復元しない場合はNULLを指定する

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `timerfd_gettime(2)`
- `timerfd_create(2)`で作成したファイルでイスクリプタに対応するタイマーの間隔・残り時間を取得

#### 引数
- `fd`、`*curr_value`を指定する
  - `*curr_value` - タイマーの残り時間値を示す`itimerspec`構造体へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す
