# 時間
- 参照: Linuxプログラミングインターフェース 10章
- 参照: 詳解UNIXプログラミング第3版 6. システムデータファイルと情報

## 時間を表す型
### まとめ
- `time_t`型 - カレンダー時間(Epochからの経過秒)
- `clock_t`型 - クロック
- `timeval`構造体 - Epochからの経過秒・マイクロ秒
- `tm`構造体 - 要素分解した時刻
- 固定形式文字列
- ユーザー指定文字列

### `timeval`構造体
```c
struct timeval {
  time_t      tv_sec;  // Epochからの経過秒
  suseconds_t tv_usec; // マイクロ秒
};
```

### `tm`構造体
```c
struct tm {
  int tm_sec;   // 秒 0-60
  int tm_min;   // 分 0-59
  int tm_hour;  // 時 0-23
  int tm_mday;  // 日 1-31
  int tm_mon;   // 月 0-11
  int tm_year;  // 年 1900からの経過年数
  int tm_wday;  // 曜日 0-6
  int tm_yday;  // 通し日数 0-365
  int tm_isdst; // 夏時間フラグ 0/1
};
```

### `tms`構造体
```c
struct tms  {
  clock_t tms_utime;  // ユーザーCPU時間
  clock_t tms_stime;  // システムCPU時間
  clock_t tms_cutime; // 終了した子のユーザーCPU時間
  clock_t tms_cstime; // 終了した子のシステムCPU時間
};
```

### `timespec`構造体
```c
struct timespec {
  time_t tv_sec;  // 秒
  long   tv_nsec; // ナノ秒
};
```

## 現在時刻の取得
### `getetimeofday(3)`
- Epochからの経過秒を`timeval`構造体で取得

#### 引数
- `*tv`、`*tz`を指定する
  - `*tv` - 結果を保存する`timeval`構造体へのポインタ
  - `*tz` - NULLを指定する
    - 元はタイムゾーンを表す`timezone`構造体へのポインタが指定されていたが現在は使用されない

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `time(2)`
- Epochからの経時秒を`time_t`型で取得

#### 引数
- `*timep`を指定する
  - `*timep` - 結果を保存する`time_t`型へのポインタ

#### 返り値
- Epochからの経過秒を返す
  - エラー時は数値-1を返す

## 変換
### `ctime(3)`
- `time_t`の値を可読な文字列へ変換

#### 引数
- `*timep`を指定する
  - `*timep` - 変換元の`time_t`型へのポインタ

#### 返り値
- 変換後の文字列(26バイト・'\0'終端)へのポインタを返す
  - エラー時はNULLを返す

- `clock_gettime(3)` - クロック時間を取得
- `clock_settime(3)` - クロック時間を設定
- `localtime(3) - タイムゾーンや夏時間を考慮の上カレンダー時間をローカル時間に変換`
- `gmtime(3) - カレンダー時間をUTC時間に変換`
- `strftime(3)` - `tm`構造体を字列を成形
- `strftime(3)` - 文字列を`tm`構造体へ変換
