# ファイルパーミッション
### `access(2)`
- プロセスの実ID / 追加グループIDを基に指定のファイルへのアクセス可否を検査する

#### 引数
- `*pathname`、`mode`を指定する
  - `*pathname` - 指定のファイルのパス名を表す文字列へのポインタ
  - `mode` - ファイルの存在、読み、書き、実行許可のいずれかを示すマクロ定数

#### 返り値
- 数値0を返す
  - 指定したアクセスモードが全て許可されなかった時は数値-1を返す

### `umask(2)`
- プロセスのumask値を変更する
  - プロセスのumask値を変更しても親プロセスのマスクには影響しない

#### 引数
- `mask`を指定する
  - `mask` - umask値を表す8進数もしくはパーミッションビットのマクロ定数

#### 返り値
- 変更前のumask値を返す

### `chmod(2)` / `fchmod(2)`
- パーミッションを変更する

#### 引数
- `chmod(2)` - `*pathname`、`mode`を指定する
  - `*pathname` - 指定のファイルのパス名を表す文字列へのポインタ
  - `mask` - umask値を表す8進数もしくはパーミッションビットのマクロ定数
- `fchmod(2)` - `fd`、`mode`を指定する
  - `fd` - 対象ファイルのファイルディスクリプタ
  - `mask` - umask値を表す8進数もしくはパーミッションビットのマクロ定数

#### 返り値
- 数値0を返す
  - エラー時は数値-1を返す

## 参照
- Linuxプログラミングインターフェース 14章 / 15章 / 16章 / 17章 / 18章
