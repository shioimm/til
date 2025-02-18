# システムリソース
### `getrusage(2)`
- 自プロセスまたは子プロセスが消費したソステムリソースの合計を返す

#### 引数
- `who`、`*res_usage`を指定する
  - `who` - 対象とするプロセスを示すマクロ定数
  - `*res_usage` - 消費リソースを格納する`rusage`構造体へのポインタ

```c
struct rusage {
  struct timeval ru_utime;   使用されたユーザー時間
  struct timeval ru_stime;   使用されたシステム時間
  long           ru_maxrss;  常駐メモリサイズ
  long           ru_majflt;  ハードページフォールト
  long           ru_minflt;  ソフトページフォールト
  long           ru_inblock; ファイルシステムによるブロック読み取り
  long           ru_oublock; ファイルシステムによるブロック書き込み
  long           ru_nvcsw;   自発的コンテキストスイッチ
  long           ru_nivcsw;  強制コンテキストスイッチ
  ...
}
```

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

### `getrlimit(2)` / `setrlimit(2)`
- `getrlimit(2)` - リソースリミットを取得する
- `setrlimit(2)` - リソースリミットを変更する

#### 引数
- `resource`、`*rlim`を指定する
  - `resource` - 参照・設定するリソース種類を示すマクロ定数
  - `*rlim` - `rlimit`構造体へのポインタ

```c
struct rlimit {
  rlim_t rlim_cur; // ソフトリミット(実際に使用されるプロセスの上限)
  rlim_t rlim_max; // ハードリミット(rlim_curの上限)
};
```

## 参照
- 例解UNIX/Linuxプログラミング教室P185-224
- 詳解UNIXプログラミング第3版 7. プロセスの環境 / 8. プロセスの制御 / 9. プロセスの関係
- Linuxプログラミングインターフェース 6章
