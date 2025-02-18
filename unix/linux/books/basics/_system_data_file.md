# システムデータファイル
## 主な種別
- パスワード - `/etc/passwd`
  - `<pwd.h>`で定義される`passwd`構造体に格納される
- シャドー - `/etc/shadow`
  - `<shadow.h>`で定義される`spwd`構造体に格納される
- グループ - `/etc/group`
  - `<grp.h>`で定義される`group`構造体に格納される
- ホスト - `/etc/hosts`
  - `<netdb.h>`で定義される`hostent`構造体に格納される
- ネットワーク - `/etc/networks`
  - `<netdb.h>`で定義される`netent`構造体に格納される
- プロトコル - `/etc/protocols`
  - `<netdb.h>`で定義される`protoent`構造体に格納される
- サービス - `/etc/services`
  - `<netdb.h>`で定義される`servent`構造体に格納される

## インターフェース
- 関数`get` - ファイルをオープンし、次のレコードを読み取る
  - 通常は構造体へのポインタを返す
  - ファイル末尾においてはnullポインタを返す
- 関数`set` - ファイルをオープンし、ファイルを巻き戻す
- 関数`end` - ファイルをクローズする

## ログイン記録
- `utmp`ファイル - 現在ログイン中の全てのユーザーを記録する
- `wtmp`ファイル - 全てのログイン・ログアウトを記録する
- ログイン時、プログラム`login`が`utmp`構造体を埋めて`utmp`ファイル/`wtmp`に書き出す
- ログアウト時、プロセス`init`が`wtmp`ファイルのログアウトエントリの`ut_name`に0を埋め込む
- `who(1)`コマンドは`utmp`ファイルを読み取る

```c
struct utmp {
  char ut_line[UT_LINESIZE]; // tty line
  char ut_name[UT_LINESIZE]; // ログイン名
  long ut_time;              // 起点からの経過秒数
};
```

## 参照
- 詳解UNIXプログラミング第3版 6. システムデータファイルと情報
